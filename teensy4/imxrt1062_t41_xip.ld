MEMORY
{
	ITCM (rwx):  ORIGIN = 0x00000000, LENGTH = 512K
	DTCM (rwx):  ORIGIN = 0x20000000, LENGTH = 512K
	RAM (rwx):   ORIGIN = 0x20200000, LENGTH = 512K
	FLASH (rwx): ORIGIN = 0x60000000, LENGTH = 7936K
}

ENTRY(ImageVectorTable)

SECTIONS
{
	.text.progmem : {
		KEEP(*(.flashconfig))
		FILL(0xFF)
		. = ORIGIN(FLASH) + 0x1000;
		KEEP(*(.ivt))
		KEEP(*(.bootdata))
		KEEP(*(.vectors))
		KEEP(*(.startup))
        *(.text*)
		*(.flashmem*)
		*(.progmem*)
                . = ALIGN(4);
                KEEP(*(.init))
                __preinit_array_start = .;
                KEEP (*(.preinit_array))
                __preinit_array_end = .;
                __init_array_start = .;
                KEEP (*(.init_array))
                __init_array_end = .;
		. = ALIGN(16);
	} > FLASH

	.text.itcm : {
		. = . + 32; 
		*(.fastrun)
		. = ALIGN(16);
	} > ITCM  AT> FLASH

	/DISCARD/ : {
		
		*(.ARM.exidx* .ARM.extab* .gnu.linkonce.armexidx.*)
		
	}
__exidx_start = ORIGIN(FLASH);
__exidx_end = ORIGIN(FLASH);

	.text.itcm.padding (NOLOAD) : {
		. = ALIGN(32768);
	} > ITCM

	.data : {
		*(.rodata*)
		*(.data*)
		. = ALIGN(16);
	} > DTCM  AT> FLASH

	.bss ALIGN(4) : {
		*(.bss*)
		*(COMMON)
		. = ALIGN(32);
		. = . + 32; 
	} > DTCM

	.bss.dma (NOLOAD) : {
		*(.dmabuffers)
		. = ALIGN(32);
	} > RAM

	_stext = ADDR(.text.itcm);
	_etext = ADDR(.text.itcm) + SIZEOF(.text.itcm);
	_stextload = LOADADDR(.text.itcm);

	_sdata = ADDR(.data);
	_edata = ADDR(.data) + SIZEOF(.data);
	_sdataload = LOADADDR(.data);

	_sbss = ADDR(.bss);
	_ebss = ADDR(.bss) + SIZEOF(.bss);

	_heap_start = ADDR(.bss.dma) + SIZEOF(.bss.dma);
	_heap_end = ORIGIN(RAM) + LENGTH(RAM);

	_extram_start = 0;
	_extram_end = 0;

	_itcm_block_count = (SIZEOF(.text.itcm) + 0x7FFF) >> 15;
	_flexram_bank_config = 0xAAAAAAAA | ((1 << (_itcm_block_count * 2)) - 1);
	_estack = ORIGIN(DTCM) + ((16 - _itcm_block_count) << 15);

	_flashimagelen = SIZEOF(.text.progmem) + SIZEOF(.text.itcm) + SIZEOF(.data);
	_teensy_model_identifier = 0x25;

	.debug_info     0 : { *(.debug_info) }
	.debug_abbrev   0 : { *(.debug_abbrev) }
	.debug_line     0 : { *(.debug_line) }
	.debug_frame    0 : { *(.debug_frame) }
	.debug_str      0 : { *(.debug_str) }
	.debug_loc      0 : { *(.debug_loc) }
}
