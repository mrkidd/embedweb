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

// ip.h: defines for IP

#ifndef H__IP
#define H__IP

void tx_ip_packet(unsigned char *tx_buffer, unsigned char tx_length);
unsigned char rx_ip_packet(unsigned char *rx_buffer);

#endif
