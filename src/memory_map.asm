// Map of project memory layout. Assembling this file places all source and assets in their correct locations.
// This file also provides named memory locations for use by any included libraries et cetera.

/*
$0000-$00FF Zeropage addressing
*/

.label cpu_data_direction = $0000
.label cpu_port_register = $0001

// temporary storage / parameters
.label zp_param_0  = $73
.label zp_param_1  = $74
.label zp_param_2  = $75
.label zp_param_3  = $76
.label zp_param_4  = $77
.label zp_param_5  = $78
.label zp_param_6  = $79
.label zp_param_7  = $7a
.label zp_param_8  = $7b

// 2-byte vectors
.label zp_vector_0 = $fb
.label zp_vector_1 = $fd

/*
$0100-$01FF Enhanced Zeropage contains the stack
$0200-$02FF Operating System and BASIC pointers
$0300-$03FF Operating System and BASIC pointers
*/

.label irq_ram_vector = $0314
.label nmi_ram_vector = $0318

/*
$0400-$07FF Screen Memory
*/

.label screen_base = $0400
.label sprite_pointer_0 = screen_base + 1016
.label sprite_pointer_1 = screen_base + 1017
.label sprite_pointer_2 = screen_base + 1018
.label sprite_pointer_3 = screen_base + 1019
.label sprite_pointer_4 = screen_base + 1020
.label sprite_pointer_5 = screen_base + 1021
.label sprite_pointer_6 = screen_base + 1022
.label sprite_pointer_7 = screen_base + 1023

/*
$0800-$9FFF Free BASIC program storage area (38911 bytes)
*/

* = $0801 "Basic Loader"
BasicUpstart(entry_point)

* = $1000 "Code"
#import "spacelib2.asm"
#import "main.asm"

* = * "Static Data"
#import "strings.asm"

* = $2000 "Sprites"
.const sprites_file = LoadBinary("../assets/sprites.bin")
.label sprites_data_pointer = * / 64
sprites_data:
    .fill sprites_file.getSize(), sprites_file.get(i)

/*
$A000-$BFFF Free machine language program storage area (when switched-out with ROM)
$C000-$CFFF Free machine language program storage area
$D000-$DDFF I/O Ports
*/

/* VIC-II registers */
.label sprite_0_x = $d000
.label sprite_0_y = $d001
.label sprite_1_x = $d002
.label sprite_1_y = $d003
.label sprite_2_x = $d004
.label sprite_2_y = $d005
.label sprite_3_x = $d006
.label sprite_3_y = $d007
.label sprite_4_x = $d008
.label sprite_4_y = $d009
.label sprite_5_x = $d00a
.label sprite_5_y = $d00b
.label sprite_6_x = $d00c
.label sprite_6_y = $d00d
.label sprite_7_x = $d00e
.label sprite_7_y = $d00f
.label sprite_x_msb = $d010

.label vic_control = $d011

.label raster_line = $d012

.label sprite_enable = $d015

.label vic_irq_control = $d019
.label vic_irq_enable = $d01a

.label sprite_multicolour_enable = $d01c

.label border_colour = $d020
.label background_colour = $d021

.label sprite_multicolour_0 = $d025
.label sprite_multicolour_1 = $d026

.label sprite_0_colour = $d027
.label sprite_1_colour = $d028
.label sprite_2_colour = $d029
.label sprite_3_colour = $d02a
.label sprite_4_colour = $d02b
.label sprite_5_colour = $d02c
.label sprite_6_colour = $d02d
.label sprite_7_colour = $d02e

.label colour_base = $d800

/* CIA-1 registers */
.label irq_control_status = $dc0d

/* CIA-2 registers */
.label nmi_control_status = $dd0d

/*
$DE00-$DFFF Reserved for interface extensions
$E000-$FFFF Free machine language program storage area (when switched-out with ROM)
*/

.label irq_rom_routine = $ea31

.label nmi_rom_vector = $fffa
.label irq_rom_vector = $fffe
