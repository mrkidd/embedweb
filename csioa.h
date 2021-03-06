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

// csioa.h: assembly routines for accessing CS8900A

#ifndef H__CSIOA
#define H__CSIOA

extern void write_byte(unsigned char io_port, unsigned char out_data);
extern unsigned char read_byte(unsigned char io_port);
extern void write_word(unsigned char io_port, unsigned int out_data);
extern unsigned int read_wordL(unsigned char io_port);
extern unsigned int read_wordH(unsigned char io_port);

#endif
