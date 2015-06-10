// Copyright (C) 2002 Mason Kidd (mrkidd@mrkidd.com)
//
// This file is part of EmbedWeb.
//
// EmbedWeb is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// EmbedWeb is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with EmbedWeb; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

// lcd_disp.h: functions for using LCD display

#ifndef H__LCD_DISP
#define H__LCD_DISP

extern void lcdout(unsigned char outchar);
extern void lcdinit(void);
extern void lcd_crlf(void);

#endif
