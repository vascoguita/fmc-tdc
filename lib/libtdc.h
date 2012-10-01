#ifndef __TDC_LIB_H__
#define __TDC_LIB_H__

#include <stdint.h>

struct tdc_board {
	int dev_id;
	int lun;
	char *devbase;
	char *sysbase;
	uint32_t chan_config; /* Channel activation */
	int ctrl[5]; /* The 5 control channels */
	int data[5]; /* The 5 data channels */
};

struct tdc_time {
	uint64_t utc;
	uint64_t ticks;
	uint64_t bins;
	uint32_t da_capo;
};

enum {
	CHAN0 = 1 << 0,
	CHAN1 = 1 << 1,
	CHAN2 = 1 << 2,
	CHAN3 = 1 << 3,
	CHAN4 = 1 << 4
};

extern struct tdc_board *tdc_open(int lun);
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

extern int tdc_activate_all_channels(struct tdc_board *b);
extern int tdc_deactivate_all_channels(struct tdc_board *b);

extern int tdc_get_circular_buffer_ptr(struct tdc_board *b, uint32_t *ptr);

extern int tdc_clear_dacapo_flag(struct tdc_board *b);

extern int tdc_read(struct tdc_board *b, int chan, struct tdc_time *t,
		    int n, int flags);
extern int tdc_fread(struct tdc_board *b, int chan, struct tdc_time *t, int n);

#endif
