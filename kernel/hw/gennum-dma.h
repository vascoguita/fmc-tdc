#ifndef __GENNUM_DMA__
#define __GENNUM_DMA__


/*
 * fa_dma_item: The information about a DMA transfer
 * @start_addr: pointer where start to retrieve data from device memory
 * @dma_addr_l: low 32bit of the dma address on host memory
 * @dma_addr_h: high 32bit of the dma address on host memory
 * @dma_len: number of bytes to transfer from device to host
 * @next_addr_l: low 32bit of the address of the next memory area to use
 * @next_addr_h: high 32bit of the address of the next memory area to use
 * @attribute: dma information about data transferm. At the moment it is used
 *             only to provide the "last item" bit, direction is fixed to
 *             device->host
 */
struct gncore_dma_item {
	uint32_t start_addr;	/* 0x00 */
	uint32_t dma_addr_l;	/* 0x04 */
	uint32_t dma_addr_h;	/* 0x08 */
	uint32_t dma_len;	/* 0x0C */
	uint32_t next_addr_l;	/* 0x10 */
	uint32_t next_addr_h;	/* 0x14 */
	uint32_t attribute;	/* 0x18 */
	uint32_t reserved;	/* ouch */
};

#define GENNUM_DMA_CTL 0x00
#define GENNUM_DMA_STA 0x04
#define GENNUM_DMA_ADDR 0x08
#define GENNUM_DMA_ADDR_L 0x0C
#define GENNUM_DMA_ADDR_H 0x10
#define GENNUM_DMA_LEN 0x14
#define GENNUM_DMA_NEXT_L 0x18
#define GENNUM_DMA_NEXT_H 0x1C
#define GENNUM_DMA_ATTR 0x20

#define GENNUM_DMA_CTL_SWP 0xc
#define GENNUM_DMA_CTL_ABORT 0x2
#define GENNUM_DMA_CTL_START 0x1
#define GENNUM_DMA_STA_DONE 1 << 0
#define GENNUM_DMA_ATTR_DIR 0x00000002
#define GENNUM_DMA_ATTR_MORE 0x00000001

#endif /* __GENNUM_DMA__ */
