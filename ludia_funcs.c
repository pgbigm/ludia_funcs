/*-------------------------------------------------------------------------
 *
 * Copyright (c) 2006-2015, NTT DATA Corporation
 * All rights reserved.
 *
 * Changelog:
 *   2013/01/09
 *   Update Ludia functions so that they are available with PostgreSQL9.1.
 *   Author: NTT DATA Corporation
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include <limits.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#include "catalog/pg_type.h"
#include "fmgr.h"
#include "funcapi.h"
#include "ludia_funcs.h"
#include "mb/pg_wchar.h"
#include "senna.h"
#include "storage/fd.h"
#include "utils/builtins.h"
#include "utils/guc.h"
#include "miscadmin.h"

#if PG_VERSION_NUM >= 90300
#include "access/htup_details.h"
#endif

PG_MODULE_MAGIC;

/* Last update date of ludia_funcs */
#define	PGS2_LAST_UPDATE	"2013.04.05"

/* GUC variables */
#ifdef PGS2_DEBUG
static bool	pgs2_enable_debug = false;
#endif
static char	*pgs2_last_update = NULL;
static int	norm_cache_limit = -1;
static bool	escape_snippet_keyword = false;

#define SEN_NORMALIZE_FLAGS 0
#define SEN_MAX_N_EXPRS		32

/* upper limit for GUC variables measured in kilobytes of memory */
/* note that various places assume the byte size fits in a "long" variable */
#if SIZEOF_SIZE_T > 4 && SIZEOF_LONG > 4
#define MAX_KILOBYTES	INT_MAX
#else
#define MAX_KILOBYTES	(INT_MAX / 1024)
#endif

#define ISBACKSLASHCHAR(x) (*(x) == '\\')
#define ISDOUBLEQUOTECHAR(x) (*(x) == '"')
#define ISSENNAOPSCHAR(x) (*(x) == '+' || *(x) == '-' || *(x) == ' ')

PG_FUNCTION_INFO_V1(pgs2snippet1);
Datum	pgs2snippet1(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(pgs2norm);
Datum	pgs2norm(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(pgs2textporter1);
Datum	pgs2textporter1(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(pgs2seninfo);
Datum	pgs2seninfo(PG_FUNCTION_ARGS);

static sen_encoding	GetSennaEncoding(void);
static sen_query	*GetSennaQuery(char *str, size_t len);
static bool			EscapeSnippetKeyword(char **s, size_t *slen);

#ifdef TEXTPORTER
#define TEXTPORTER_TMPDIR			"/tmp"
#define TEXTPORTER_MKSTEMP_UMASK 		0177
#define TEXTPORTER_GROUPNAME		"UTF-8"
#define TEXTPORTER_DEFLANGNAME		"Japanese"
#define TEXTPORTER_BBIGENDIAN		1
#define TEXTPORTER_OPTION			0x00000020	/* DMC_GETTEXT_OPT_LF */
#define TEXTPORTER_OPTION_STRING	"32"
#define TEXTPORTER_OPTION1			0x00010000	/* DMC_GETTEXT_OPT1_TXCONV */
#define TEXTPORTER_SIZE				0
#define TEXTPORTER_CSV_C			0


/* GUC variables for pgs2textpoter1 */
static int	textporter_error = ERROR;
static unsigned int	textporter_option = TEXTPORTER_OPTION;

/*
 * This variable is a dummy that doesn't do anything, except in some
 * cases provides the value for SHOW to display.  The real state is
 * elsewhere and is kept in sync by assign_hooks.
 */
static char	*textporter_option_string;

static const struct config_enum_entry textporter_error_options[] = {
	{"debug1", DEBUG1, false},
	{"log", LOG, false},
	{"info", INFO, false},
	{"notice", NOTICE, false},
	{"warning", WARNING, false},
	{"error", ERROR, false},
	{NULL, 0, false}
};

static void CleanupTextPorterTmpFiles(void);

static bool check_textporter_option(char **newval, void **extra, GucSource source);
static void assign_textporter_option(const char *newval, void *extra);
#endif	/* TEXTPORTER */

void	_PG_init(void);
void	_PG_fini(void);

void
_PG_init(void)
{
	sen_rc		rc;

#ifdef PGS2_DEBUG
	/* Define custom GUC variable for debugging */
	DefineCustomBoolVariable("ludia_funcs.enable_debug",
							 "Emit ludia_funcs debugging output.",
							 NULL,
							 &pgs2_enable_debug,
							 false,
							 PGC_USERSET,
							 0,
							 NULL,
							 NULL,
							 NULL);
#endif

	/* Can't be set in postgresql.conf */
	DefineCustomStringVariable("ludia_funcs.last_update",
							   "Shows the last update date of ludia_funcs.",
							   NULL,
							   &pgs2_last_update,
							   PGS2_LAST_UPDATE,
							   PGC_INTERNAL,
							   GUC_REPORT | GUC_NOT_IN_SAMPLE | GUC_DISALLOW_IN_FILE,
							   NULL,
							   NULL,
							   NULL);

#ifdef TEXTPORTER
	/* Define custom GUC variables */
	DefineCustomEnumVariable("ludia_funcs.textporter_error",
							 "Sets the message levels that are emitted "
							 "when textporter fails.",
							 NULL,
							 &textporter_error,
							 ERROR,
							 textporter_error_options,
							 PGC_SUSET,
							 0,
							 NULL,
							 NULL,
							 NULL);

	DefineCustomStringVariable("ludia_funcs.textporter_option",
							   "Sets the option used to get text data "
							   "from TextPorter",
							   NULL,
							   &textporter_option_string,
							   TEXTPORTER_OPTION_STRING,
							   PGC_SUSET,
							   0,
							   check_textporter_option,
							   assign_textporter_option,
							   NULL);

	/* Clean up remaining textporter temporary files */
	CleanupTextPorterTmpFiles();
#endif	/* TEXTPORTER */

	/*
	 * A value of 0 means no limit on the cache size. A value of -1 means
	 * that work_mem is used as the upper size limit of the cache.
	 */
	DefineCustomIntVariable("ludia_funcs.norm_cache_limit",
							"Sets the maximum memory to be used for caching "
							"the result of pgs2norm()",
							NULL,
							&norm_cache_limit,
							-1,
							-1,
							MAX_KILOBYTES,
							PGC_USERSET,
							GUC_UNIT_KB,
							NULL,
							NULL,
							NULL);

	DefineCustomBoolVariable("ludia_funcs.escape_snippet_keyword",
							 "Escapes snippet keyword string.",
							 NULL,
							 &escape_snippet_keyword,
							 false,
							 PGC_USERSET,
							 0,
							 NULL,
							 NULL,
							 NULL);

	EmitWarningsOnPlaceholders("ludia_funcs");

	/* Initialize Senna */
	rc = sen_init();
	if (rc != sen_success)
		ereport(ERROR,
				(errmsg("sen_init() failed: %d", rc)));
}

void
_PG_fini(void)
{
}

#ifdef TEXTPORTER
#define REMOVE_TMPFILE(path)											\
	do {																\
		if (unlink(path) != 0)											\
			ereport(WARNING,											\
					(errcode_for_file_access(),							\
					 errmsg("could not remove temporary file \"%s\": %m", path))); \
	} while(0)

Datum
pgs2textporter1(PG_FUNCTION_ARGS)
{
	char	*appfile = text_to_cstring(PG_GETARG_TEXT_P(0));
	char	txtfile[] = TEXTPORTER_TMPDIR "/ludia_funcs_XXXXXX";
	int		tmpfd;
	int		ret;
	FILE	*fp;
	text	*result = NULL;
	struct stat	statbuf;
	bool	return_null = false;
	mode_t	oumask;

	/* Confirm that database encoding is UTF-8 */
	GetSennaEncoding();

	PG_TRY();
	{
		/*
		 * Generate a unique temporary filename where text data gotten
		 * from application file by TextPorter is stored temporarily.
		 * Set the permission of a temporary file to 0600 to ensure that
		 * only the owner of PostgreSQL server can read and write the file.
		 */
		oumask = umask(TEXTPORTER_MKSTEMP_UMASK);
		tmpfd = mkstemp(txtfile);
		umask(oumask);

		if (tmpfd < 0)
			ereport(ERROR,
					(errcode_for_file_access(),
					 errmsg("could not generate a unique temporary filename: %m")));
		if (close(tmpfd) != 0)
			ereport(ERROR,
					(errcode_for_file_access(),
					 errmsg("could not close temporary file \"%s\": %m", txtfile)));

		/*
		 * Run TextPorter to read text data from application file (appfile)
		 * to temporary file (txtfile).
		 */
		ret = ExecTextPorter((unsigned char *)appfile,
							 (unsigned char *)txtfile,
							 (unsigned char *)TEXTPORTER_GROUPNAME,
							 (unsigned char *)TEXTPORTER_DEFLANGNAME,
							 TEXTPORTER_BBIGENDIAN, textporter_option,
							 TEXTPORTER_OPTION1, TEXTPORTER_SIZE,
							 TEXTPORTER_CSV_C);
		if (ret != 0)
		{
			ereport(textporter_error,
					(errmsg("could not get text from application file \"%s\"",
							appfile),
					 errdetail("DMC_GetText_V5() failed with errcode %d",
							   ret)));

			/* Return NULL if textporter_error is set to other than ERROR */
			return_null = true;
		}
		else
		{
			/* Read text data from temporary file to memory */
			if (stat(txtfile, &statbuf))
				ereport(ERROR,
						(errcode_for_file_access(),
						 errmsg("could not stat file \"%s\": %m", txtfile)));
			result = (text *) palloc(statbuf.st_size + VARHDRSZ);

			fp = AllocateFile(txtfile, "r");
			if (fp == NULL)
				ereport(ERROR,
						(errcode_for_file_access(),
						 errmsg("could not open file \"%s\": %m", txtfile)));

			if (fread(VARDATA(result), 1, statbuf.st_size, fp) != statbuf.st_size ||
				ferror(fp))
				ereport(ERROR,
						(errcode_for_file_access(),
						 errmsg("could not read file \"%s\": %m", txtfile)));

			FreeFile(fp);
		}

		REMOVE_TMPFILE(txtfile);
		pfree(appfile);
	}
	PG_CATCH();
	{
		REMOVE_TMPFILE(txtfile);
		PG_RE_THROW();
	}
	PG_END_TRY();

	if (return_null)
		PG_RETURN_NULL();

	SET_VARSIZE(result, statbuf.st_size + VARHDRSZ);

	PG_RETURN_TEXT_P(result);
}

/*
 * Clean up remaining textporter temporary files
 */
static void
CleanupTextPorterTmpFiles(void)
{
	DIR				*tpdir;
	struct dirent	*tpde;
	char			path[MAXPGPATH];

	tpdir = AllocateDir(TEXTPORTER_TMPDIR);
	if (tpdir == NULL)
		ereport(ERROR,
				(errcode_for_file_access(),
				 errmsg("could not open textporter temporary file directory \"%s\": %m",
						TEXTPORTER_TMPDIR)));

	while ((tpde = ReadDir(tpdir, TEXTPORTER_TMPDIR)) != NULL)
	{
		if (strlen(tpde->d_name) == 18 &&
			strncmp(tpde->d_name, "ludia_funcs_", 12) == 0)
		{
			snprintf(path, MAXPGPATH, TEXTPORTER_TMPDIR "/%s", tpde->d_name);
			REMOVE_TMPFILE(path);
		}
	}

	FreeDir(tpdir);
}

static bool
check_textporter_option(char **newval, void **extra, GucSource source)
{
	unsigned long	val;
	char			*endptr;
	unsigned int	*myextra;

	errno = 0;
	val = strtoul(*newval, &endptr, 0);

	if (*endptr != '\0')
		return false;

	if (errno == ERANGE || val != (unsigned long) ((unsigned int) val))
	{
		GUC_check_errhint("Value exceeds unsigned integer range.");
		return false;
	}

	/* Set up the "extra" struct actually used by assign_textporter_option */
	myextra = (unsigned int *) malloc(sizeof(unsigned int));
	if (myextra == NULL)
	{
		GUC_check_errcode(ERRCODE_OUT_OF_MEMORY);
		GUC_check_errmsg("out of memory");
		return false;
	}
	*myextra = (unsigned int) val;
	*extra = (void *) myextra;

	return true;
}

static void
assign_textporter_option(const char *newval, void *extra)
{
	textporter_option = *((unsigned int *) extra);
}

#else	/* TEXTPORTER */

Datum
pgs2textporter1(PG_FUNCTION_ARGS)
{
	PG_RETURN_NULL();
}

#endif	/* TEXTPORTER */

static sen_encoding
GetSennaEncoding(void)
{
	static sen_encoding		encoding = sen_enc_default;

	if (encoding == sen_enc_default)
	{
		if (GetDatabaseEncoding() == PG_UTF8)
			encoding = sen_enc_utf8;
		else
			ereport(ERROR,
					(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
					 errmsg("does not support database encoding \"%s\"",
							GetDatabaseEncodingName())));
	}
	return encoding;
}

/*
 * Escape the backslash and double quote characters in the given string.
 *
 * Return false if the given string has no character which needs to be
 * escaped. Otherwise, return true. In this case, **s points the palloc'd
 * space storing the escaped keyword string and *slen is set to the size
 * of that string. The caller needs to free the palloc'd space.
 */
static bool
EscapeSnippetKeyword(char **s, size_t *slen)
{
	const char	*sp;
	char		*ep;
	char		*escaped;
	int			mblen;
	int			copylen;
	bool		in_doublequote = false;
	bool		in_sennaops = false;
	bool		need_escape = false;

	/*
	 * Skip the heading double quote character because it always doesn't
	 * need to be interpreted as a character itself and be escaped.
	 * Note that we must not skip the heading character if it's not a
	 * double quote.
	 */
	sp = *s;
	if (ISDOUBLEQUOTECHAR(sp))
		sp++;

	/*
	 * Check whether the snippet keyword string has a character which
	 * needs to be escaped.
	 */
	while ((sp - *s) < *slen)
	{
		mblen = pg_mblen(sp);

		/*
		 * Backslash in the keyword always needs to be escaped.
		 */
		if (ISBACKSLASHCHAR(sp))
		{
			need_escape = true;
			break;
		}

		if (in_doublequote)
		{
			if (ISSENNAOPSCHAR(sp))
			{
				in_sennaops = true;
				in_doublequote = false;
			}
			else
			{
				/*
				 * Double quote in the keyword needs to be escaped if
				 * any Senna search operators are to neither its right
				 * nor left.
				 */
				need_escape = true;
				break;
			}
		}
		else
		{
			if (ISDOUBLEQUOTECHAR(sp) && !in_sennaops)
				in_doublequote = true;
			if (!ISSENNAOPSCHAR(sp))
				in_sennaops = false;
		}

		sp += mblen;
	}

	/*
	 * Quick exit if the keyword has no character which needs to be
	 * escaped.
	 */
	if (!need_escape)
		return false;

	/*
	 * Allocate the buffer space to store the escaped snippet keyword string.
	 * The maximum size of escaped string is double the input keyword size.
	 * The size reaches the maximum when every character in the input keyword
	 * needs to be escaped.
	 */
	ep = escaped = (char *) palloc(*slen * 2);

	/*
	 * Copy the characters which have been passed through in the above loop
	 * and don't need to be escaped, into the buffer. If in_doublequote is
	 * true, we don't copy the double quote in the previous position into the
	 * buffer because it might still need to be escaped.
	 */
	copylen = sp - *s - ((in_doublequote) ? 1 : 0);
	memcpy(ep, *s, copylen);
	ep += copylen;

	/*
	 * Construct the escaped snippet keyword string.
	 */
	while ((sp - *s) < *slen)
	{
		mblen = pg_mblen(sp);

		if (in_doublequote)
		{
			/*
			 * dqchar indicates the previous character, that is a double
			 * quote. We assume here that a double quote is single-byte
			 * character.
			 */
			char dqchar	= *(sp - 1);

			if (ISSENNAOPSCHAR(sp))
			{
				/*
				 * Don't escape the double quote which is just before Senna
				 * operator.
				 */
				*ep++ = dqchar;
				*ep++ = *sp;
				in_sennaops = true;
				in_doublequote = false;
			}
			else
			{
				/*
				 * Escape the double quote if no Senna operator is next to it.
				 */
				*ep++ = '\\';
				*ep++ = dqchar;

				if (ISDOUBLEQUOTECHAR(sp))
					in_doublequote = true;
				else
				{
					if (ISBACKSLASHCHAR(sp))
						*ep++ = '\\';
					memcpy(ep, sp, mblen);
					ep += mblen;
					in_doublequote = false;
				}
			}
		}
		else
		{
			if (ISDOUBLEQUOTECHAR(sp))
			{
				/*
				 * Don't escape the double quote which is just after Senna
				 * operator.
				 */
				if (in_sennaops)
					*ep++ = *sp;
				else
					in_doublequote = true;
			}
			else
			{
				if (ISBACKSLASHCHAR(sp))
					*ep++ = '\\';
				/*
				 * We don't check ISSENNAOPSCHAR() here. We handle Senna
				 * operator character as a character itself instead of
				 * an operator if it doesn't follow a double quote.
				 */
				memcpy(ep, sp, mblen);
				ep += mblen;
			}

			if (!ISSENNAOPSCHAR(sp))
				in_sennaops = false;
		}

		sp += mblen;
	}

	/* Add the tailing double quote into the buffer */
	if (in_doublequote)
		*ep++ = *(sp - 1);

	*s = escaped;
	*slen = ep - *s;

#ifdef PGS2_DEBUG
	if (pgs2_enable_debug)
	{
		char	*tmp = pnstrdup(*s, *slen);

		elog(LOG, "escaped snippet keyword: %s", tmp);
		pfree(tmp);
	}
#endif

	return true;
}

static sen_query *
GetSennaQuery(char *str, size_t len)
{
	static sen_query	*query_cache = NULL;
	static char			*key_cache = NULL;
	static size_t		len_cache = 0;
	static bool			guc_cache = false;
	sen_query	*query;
	sen_encoding	encoding;
	char		*key;
	size_t		key_len;
	int			rest;
	bool		needfree = false;

	/*
	 * Return the cached Senna query if the same keyword has
	 * been used the last time.
	 */
	if (key_cache != NULL &&
		len == len_cache &&
		strncmp(key_cache, str, len) == 0 &&
		escape_snippet_keyword == guc_cache)
	{
#ifdef PGS2_DEBUG
		if (pgs2_enable_debug)
		{
			char	*tmp = pnstrdup(str, len);

			elog(LOG, "GetSennaQuery(): quick exit: %s", tmp);
			pfree(tmp);
		}
#endif
		return query_cache;
	}

	encoding = GetSennaEncoding();

	key = malloc(len);
	if (key == NULL)
		ereport(ERROR,
				(errcode(ERRCODE_OUT_OF_MEMORY),
				 errmsg("out of memory")));

	/*
	 * We always cache the unescaped keyword. Which enables us
	 * to check whether we can use the cached Senna query before
	 * escaping the keyword.
	 */
	memcpy(key, str, len);
	key_len = len;

	/*
	 * If the keyword has been escaped, 'str' points to the
	 * newly-palloc'd space storing the escaped keyword. This
	 * space needs to be freed later.
	 */
	if (escape_snippet_keyword)
		needfree = EscapeSnippetKeyword(&str, &len);

	query = sen_query_open(str, len, sen_sel_or, SEN_MAX_N_EXPRS,
						   encoding);
	if (query == NULL)
	{
		free(key);
		ereport(ERROR,
				(errmsg("sen_query_open() failed")));
	}

	if ((rest = sen_query_rest(query, NULL)) != 0)
		ereport(WARNING,
				(errmsg("too many expressions (%d)", rest)));

	if (query_cache != NULL)
	{
		sen_query_close(query_cache);
		free(key_cache);
	}

	key_cache = key;
	len_cache = key_len;
	query_cache = query;
	guc_cache = escape_snippet_keyword;

	if (needfree)
		pfree(str);

	return query;
}

Datum
pgs2snippet1(PG_FUNCTION_ARGS)
{
	int			flags = PG_GETARG_INT32(0);
	uint32		width = PG_GETARG_UINT32(1);
	uint32		max_results = PG_GETARG_UINT32(2);
	text	   *opentags = PG_GETARG_TEXT_P(3);
	text	   *closetags = PG_GETARG_TEXT_P(4);
	int			mapping = PG_GETARG_INT32(5);
	text	   *keywords = PG_GETARG_TEXT_P(6);
	text	   *document = PG_GETARG_TEXT_P(7);
	sen_query  *query;
	sen_snip   *snip = NULL;
	const char *opentags_str = VARDATA_ANY(opentags);
	const char *closetags_str = VARDATA_ANY(closetags);
	char	   *keywords_str = VARDATA_ANY(keywords);
	char	   *document_str = VARDATA_ANY(document);
	uint32		opentags_len = VARSIZE_ANY_EXHDR(opentags);
	uint32		closetags_len = VARSIZE_ANY_EXHDR(closetags);
	uint32		keywords_len = VARSIZE_ANY_EXHDR(keywords);
	uint32		document_len = VARSIZE_ANY_EXHDR(document);
	uint32		nresults = 0;
	uint32		max_tagged_len = 0;
	sen_rc		rc;
	text	   *result;
	uint32		result_len = 0;
	bool		return_null = false;

	query = GetSennaQuery(keywords_str, keywords_len);

	snip = sen_query_snip(query, flags, width, max_results, 1,
						  &opentags_str, &opentags_len,
						  &closetags_str, &closetags_len,
						  mapping == 0 ? NULL : (sen_snip_mapping *)-1);
	if (snip == NULL)
		ereport(ERROR,
				(errmsg("sen_query_snip() failed")));

	PG_TRY();
	{
		rc = sen_snip_exec(snip, document_str, document_len,
						   &nresults, &max_tagged_len);
		if (rc != sen_success)
			ereport(ERROR,
					(errmsg("sen_snip_exec() failed: %d", rc)));

		result = (text *) palloc(max_tagged_len + VARHDRSZ);

		rc = sen_snip_get_result(snip, 0, VARDATA(result), &result_len);
		if (rc == sen_invalid_argument)
			return_null = true;
		else if (rc != sen_success)
			ereport(ERROR,
					(errmsg("sen_snip_get_result() failed: %d", rc)));
	}
	PG_CATCH();
	{
		sen_snip_close(snip);
		PG_RE_THROW();
	}
	PG_END_TRY();

	sen_snip_close(snip);

	if (return_null)
		PG_RETURN_NULL();

	SET_VARSIZE(result, max_tagged_len + VARHDRSZ);

	PG_RETURN_TEXT_P(result);
}

/*
 * Make sure there is enough space for 'needed' more bytes.
 *
 * Sets **buf to the allocated space which can store the needed bytes if OK,
 * NULL if failed to enlarge the space because 'needed' is larger than 'maxlen'.
 */
static inline void
pgs2malloc(void **buf, long *buflen, long needed, long maxlen)
{
#ifdef PGS2_DEBUG
	if (pgs2_enable_debug)
		elog(LOG, "pgs2malloc(): buflen %ld, needed %ld, maxlen %ld",
			 *buflen, needed, maxlen);
#endif

	if (*buf != NULL && *buflen >= needed && (*buflen <= maxlen || maxlen == 0))
		return;		/* got enough space already */

	/*
	 * Release the already-allocated space since it's too small to
	 * store the needed bytes or larger than the upper limit.
	 */
	if (*buf != NULL)
	{
		free(*buf);
		*buf = NULL;
		*buflen = 0;
	}

	/*
	 * Don't allocate any space if the needed space is larger than
	 * the upper limit.
	 */
	if (needed > maxlen && maxlen != 0)
		return;

	/*
	 * Allocate the space for the needed bytes.
	 *
	 * We don't want to allocate just a little more space with each enlarge;
	 * for efficiency, double the buffer size each time it overflows.
	 * Actually, we might need to more than double it if 'needed' is big...
	 *
	 * We check whether '*buflen' overflows each cycle to avoid infinite loop.
	 */
	*buflen = 1024L;
	while (*buflen < needed && *buflen != 0)
		*buflen <<= 1;

	/*
	 * Clamp to maxlen in case we went past it.  Note we are assuming
	 * here that maxlen <= LONG_MAX/2, else the above loop could
	 * overflow.  We will still have *buflen >= needed.
	 */
	if (*buflen > maxlen && maxlen != 0)
		*buflen = maxlen;

	/* Guard against out-of-range '*buflen' value */
	if (*buflen == 0)
		ereport(ERROR,
				(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
				 errmsg("out of memory"),
				 errdetail("Cannot enlarge buffer by %ld more bytes.",
						   needed)));

	*buf = (void *) malloc(*buflen);
	if (*buf == NULL)
		ereport(ERROR,
				(errcode(ERRCODE_OUT_OF_MEMORY),
				 errmsg("out of memory")));
}

Datum
pgs2norm(PG_FUNCTION_ARGS)
{
	text		*str = PG_GETARG_TEXT_PP(0);
	char		*s = VARDATA_ANY(str);
	long		slen = VARSIZE_ANY_EXHDR(str);
	text		*result = NULL;
	long		buflen;
	long		reslen;
	long		maxlen;
	long		needed;

	/*
	 * norm_cache is the cache memory storing both input and normalized strings
	 * as the result of pgs2norm(). norm_cache_size is the size of norm_cache
	 * and its upper limit is specified by norm_cache_limit parameter. norm_result
	 * is the pointer to the normalized string with the verlena header (i.e.,
	 * text type) stored in the latter half of the cache. norm_reslen is the size
	 * of norm_result. norm_slen is the size of the input string which is stored
	 * in the first half of the cache.
	 */
	static char		*norm_cache = NULL;
	static long		norm_cache_size = 0;
	static long		norm_slen = 0;
	static char		*norm_result = NULL;
	static long		norm_reslen = 0;

	/*
	 * Return the cached normalization result if the same string of
	 * the given one has been normalized the last time.
	 */
	if (norm_cache != NULL &&
		norm_slen == slen &&
		strncmp(norm_cache, s, slen) == 0)
	{
#ifdef PGS2_DEBUG
		if (pgs2_enable_debug)
		{
			char	*tmp = text_to_cstring(str);

			elog(LOG, "pgs2norm(): quick exit: %s", tmp);
			pfree(tmp);
		}
#endif

		PG_RETURN_TEXT_P(pnstrdup(norm_result, norm_reslen));
	}

	/* Confirm that database encoding is UTF-8 */
	GetSennaEncoding();

	/*
	 * Allocate the result buffer to store the normalized string. Since the size of
	 * normalized string can be larger than that of input one, the result buffer needs
	 * extra space. Problem is that, before calling sen_str_normalize, we need to
	 * allocate the result buffer but cannot know how large extra space is required.
	 * So we use RESULT_EXTRA_SIZE as the estimated size of extra space here.
	 */
#define RESULT_EXTRA_SIZE	64
	buflen = slen + RESULT_EXTRA_SIZE;

retry:
	result = (text *) palloc(buflen + VARHDRSZ);

#if defined(FAST_SENNA)
	reslen = fast_sen_str_normalize(s, slen, VARDATA(result), buflen);
#else
	reslen = sen_str_normalize(s, slen, sen_enc_utf8,
							   SEN_NORMALIZE_FLAGS,
							   VARDATA(result), buflen);
#endif

	if (reslen < 0)
		ereport(ERROR,
				(errmsg("could not normalize the string")));

	/*
	 * If the result buffer size is too short to store the normalized string,
	 * we enlarge the buffer and retry the string normalization.
	 */
	if (buflen <= reslen)
	{
		pfree(result);
		buflen = reslen + 1;
		goto retry;
	}

	SET_VARSIZE(result, reslen + VARHDRSZ);

	/*
	 * Cache both input and normalized strings to accelerate the subsequent
	 * calls of pgs2norm() with the same input string. But we don't do that
	 * if the maximum allowed size of the cache is too small to store them.
	 */
	needed = slen + reslen + VARHDRSZ;
	maxlen = ((norm_cache_limit >= 0) ? norm_cache_limit : work_mem) * 1024L;

	pgs2malloc((void **) &norm_cache, &norm_cache_size, needed, maxlen);
	if (norm_cache != NULL)
	{
		/* Store the input string into the first half of the cache */
		norm_slen = slen;
		memcpy(norm_cache, s, slen);

		/*
		 * Store the normalized string with the varlena header (i.e., text type)
		 * into the latter half of the cache.
		 */
		norm_result = norm_cache + slen;
		norm_reslen = reslen + VARHDRSZ;
		memcpy(norm_result, result, norm_reslen);
	}

#ifdef PGS2_DEBUG
	if (pgs2_enable_debug)
	{
		char	*tmp = text_to_cstring(str);

		elog(LOG, "pgs2norm(): complete (%s result cache): %s",
			 (norm_cache == NULL) ? "unset" : "set", tmp);
		pfree(tmp);
	}
#endif

	PG_RETURN_TEXT_P(result);
}

/*
 * Report the version and configure options of Senna which
 * ludia_funcs depends on.
 */
Datum
pgs2seninfo(PG_FUNCTION_ARGS)
{
	char	*version[MAXPGPATH];
	char	*coptions[MAXPGPATH];
	Datum   values[2];
	bool    isnull[2];
	HeapTuple tuple;
	TupleDesc tupdesc;

	/*
	 * Get the version and configure options of Senna. Ignore the
	 * return value of sen_info() because it always returns a success.
	 */
	sen_info((char **)&version, (char **)&coptions, NULL, NULL, NULL, NULL);

	/*
	 * Construct a tuple descriptor for the result row. This must
	 * match this function's ludia_funcs--x.x.sql entry.
	 */
	tupdesc = CreateTemplateTupleDesc(2, false);
	TupleDescInitEntry(tupdesc, (AttrNumber) 1,
					   "version", TEXTOID, -1, 0);
	TupleDescInitEntry(tupdesc, (AttrNumber) 2,
					   "configure_options", TEXTOID, -1, 0);
	tupdesc = BlessTupleDesc(tupdesc);

	/* version */
	values[0] = CStringGetTextDatum(*version);
	isnull[0] = false;

	/* configure option */
	values[1] = CStringGetTextDatum(*coptions);
	isnull[1] = false;

	tuple = heap_form_tuple(tupdesc, values, isnull);
	PG_RETURN_DATUM(HeapTupleGetDatum(tuple));
}
