#ifndef __TDC_LIB_H__
#define __TDC_LIB_H__

#include <stdint.h>

struct tdc_board {
	int dev_id;
	char *devbase;
	char *sysbase;
	int ctrl[5]; /* The 5 control channels */
	int data[5]; /* The 5 data channels */
};

struct tdc_time {
	uint64_t utc;
	uint32_t coarse;
	uint32_t frac;
	uint32_t channel;
};


extern int tdc_init(void);
extern void tdc_exit(void);

extern struct tdc_board *tdc_open(int offset, int dev_id);
extern int tdc_close(struct tdc_board *b);

extern int tdc_start_acquisition(struct tdc_board *b);
extern int tdc_stop_acquisition(struct tdc_board *b);

extern int tdc_set_host_utc_time(struct tdc_board *b);
extern int tdc_set_utc_time(struct tdc_board *b, uint32_t utc);
extern int tdc_get_utc_time(struct tdc_board *b, uint32_t *utc);

extern int tdc_set_dac_word(struct tdc_board *b, uint32_t dw);
extern int tdc_get_dac_word(struct tdc_board *b, uint32_t *dw);

extern int tdc_set_time_threshold(struct tdc_board *b, uint32_t thres);
extern int tdc_get_time_threshold(struct tdc_board *b, uint32_t *thres);

extern int tdc_set_timestamp_threshold(struct tdc_board *b, uint32_t thres);
extern int tdc_get_timestamp_threshold(struct tdc_board *b, uint32_t *thres);

extern int tdc_set_active_channels(struct tdc_board *b, uint32_t config);
extern int tdc_get_active_channels(struct tdc_board *b, uint32_t *config);

#endif
