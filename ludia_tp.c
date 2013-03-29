/*-------------------------------------------------------------------------
 *
 * Copyright (c) 2006-2013, NTT DATA Corporation
 * All rights reserved.
 *
 * Changelog:
 *   2013/01/09
 *   Update Ludia functions so that they are available with PostgreSQL9.1.
 *   Author: NTT DATA Corporation
 *
 *-------------------------------------------------------------------------
 */
#ifdef TEXTPORTER
#include "ludia_funcs.h"

#include <string.h>
#include <text_oem.h>

int
ExecTextPorter(unsigned char *Appfile, unsigned char *Txtfile,
			   unsigned char *GroupName, unsigned char *DefLangName,
			   int bBigEndian, unsigned int Option,
			   unsigned int Option1, long Size, unsigned short Csv_c)
{
	DMC_TEXTINFO_V5	textinfo;

	strncpy((char *)textinfo.GroupName, (const char *)GroupName, MAX_GROUP_NAME);
	strncpy((char *)textinfo.DefLangName, (const char *)DefLangName, MAX_LANG_NAME);
	textinfo.bBigEndian = bBigEndian;
	textinfo.Option = Option;
	textinfo.Option1 = Option1;
	textinfo.Size = Size;
	textinfo.Csv_c = Csv_c;

	return DMC_GetText_V5((Byte *)Appfile, (Byte *)Txtfile,
						  &textinfo, NULL);
}

#endif	/* TEXTPORTER */
