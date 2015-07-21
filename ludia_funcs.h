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
#ifndef __LUDIA_FUNCS_H__
#define __LUDIA_FUNCS_H__

#ifdef TEXTPORTER
int	ExecTextPorter(unsigned char *Appfile, unsigned char *Txtfile,
				   unsigned char *GroupName, unsigned char *DefLangName,
				   int bBigEndian, unsigned int Option,
				   unsigned int Option1, long Size, unsigned short Csv_c);
#endif	/* TEXTPORTER */

#endif	/* __LUDIA_FUNCS_H */
