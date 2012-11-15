/**
 * @file libtdc.h
 *
 * @brief FMC TDC driver library interface
 *
 * This file describes the external interface to the FMCTDC
 * driver and provides the definitions for proper communication
 * with the device
 *
 * Copyright (c) 2012 CERN
 * @author Samuel Iglesias Gonsalvez <siglesias@igalia.com>
 * @date Oct 24th 2012
 *
 * @section license_sec License
 * Released under the GPL v2. (and only v2, not any later version)
 */

/*! \file */
/*!
 *  \mainpage FMC TDC Device Driver
 *  \author Samuel Iglesias Gonsalvez, Igalia S.L.
 *  \version 24 Oct 2012
 *
 * An FPGA Mezzanine Card (FMC) with a Time to Digital Converter chip to perform
 * one-shot sub-nanosecond time interval measurements.
 *
 * HW OHWR project: http://www.ohwr.org/projects/fmc-tdc
 *
 * SW OHWR project: http://www.ohwr.org/projects/fmc-tdc-sw
 *
 * Copyright (c) 2012 CERN
 */
#ifndef __TDC_LIB_H__
#define __TDC_LIB_H__

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/*!
 * This struct is used as argument in almost all the functions.
 *  The user should not modify its attributes!
 */
struct tdc_board {
	int dev_id;
	int lun;
	char *devbase;
	char *sysbase;
	uint32_t chan_config; /* Channel activation */
	int ctrl[5]; /* The 5 control channels */
	int data[5]; /* The 5 data channels */
};

/*!
 * This struct is used in tdc_read(). It is the event buffer.
 */
struct tdc_time {
	uint64_t utc;
	uint64_t ticks;
	uint64_t bins;
	uint32_t da_capo;
};

/*!
 * This enum can be used in tdc_{s,g}et_channels_term() functions.
 */
enum {
	CHAN0 = 1 << 0,
	CHAN1 = 1 << 1,
	CHAN2 = 1 << 2,
	CHAN3 = 1 << 3,
	CHAN4 = 1 << 4
};

/**
 * @brief Get a handle for a FMCTDC device
 *
 * @param lun - LUN for fmc-tdc card
 *
 * @return - pointer to struct tdc_board.
 *
 */
extern struct tdc_board *tdc_open(int lun);

/**
 * @brief Close a FMCTDC device
 *
 * @param b - pointer to struct tdc_board
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_close(struct tdc_board *b);

/**
 * @brief Allocate a event buffer.
 *
 * @param events - number of elements of the buffer
 *
 * @return - struct tdc_time pointer.
 *
 */
extern struct tdc_time *tdc_zalloc(unsigned int events);

/**
 * @brief Free a event buffer.
 *
 * @param buffer - Buffer to be free'd
 *
 */
extern void tdc_free(struct tdc_time *buffer);

/**
 * @brief Start acquiring events
 *
 * @param b - pointer to struct tdc_board
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_start_acquisition(struct tdc_board *b);

/**
 * @brief Stop acquiring events
 *
 * @param b - pointer to struct tdc_board
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_stop_acquisition(struct tdc_board *b);

/**
 * @brief Set host UTC time to FMCTDC board
 *
 * @param b - pointer to struct tdc_board
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_set_host_utc_time(struct tdc_board *b);

/**
 * @brief Set UTC time to FMCTDC board
 *
 * @param b - pointer to struct tdc_board
 * @param utc - UTC value to be written, in seconds. EPOC format.
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_set_utc_time(struct tdc_board *b, uint32_t utc);

/**
 * @brief Get UTC time to FMCTDC board
 *
 * @param b - pointer to struct tdc_board
 * @param utc - Read UTC value, in seconds. EPOC format.
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_get_utc_time(struct tdc_board *b, uint32_t *utc);

/**
 * @brief Set DAC to FMCTDC board
 *
 * @param b - pointer to struct tdc_board
 * @param dw - DAC word value to be written.
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_set_dac_word(struct tdc_board *b, uint32_t dw);

/**
 * @brief Set DAC to FMCTDC board
 *
 * @param b - pointer to struct tdc_board
 * @param dw - DAC word value to be read.
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_get_dac_word(struct tdc_board *b, uint32_t *dw);

/**
 * @brief Set time threshold
 *
 * The time threshold is the maximum time we will not have an IRQ if there is no
 * enough number of events acquired (configured by timestamp threshold). This
 * value must be a 32 bits positive value.
 *
 * It doens't means that we have always pending events.
 *
 * @param b - pointer to struct tdc_board
 * @param thres - Time threshold, in seconds.
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_set_time_threshold(struct tdc_board *b, uint32_t thres);

/**
 * @brief Get time threshold
 *
 * The time threshold is the maximum time we will not have an IRQ if there is no
 * enough number of events acquired (configured by timestamp threshold).
 *
 * It doens't means that we have always pending events.
 *
 * @param b - pointer to struct tdc_board
 * @param thres - Time threshold, in seconds.
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_get_time_threshold(struct tdc_board *b, uint32_t *thres);

/**
 * @brief Set timestamp threshold
 *
 * The timestamp threshold is the number of events we want per interrupt.
 * The value must be between 0 and 64.
 *
 * @param b - pointer to struct tdc_board
 * @param thres - Timestamp threshold, in seconds.
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_set_timestamp_threshold(struct tdc_board *b, uint32_t thres);

/**
 * @brief Get timestamp threshold
 *
 * The timestamp threshold is the number of events we want per interrupt.
 *
 * @param b - pointer to struct tdc_board
 * @param thres - Timestamp threshold, in seconds.
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_get_timestamp_threshold(struct tdc_board *b, uint32_t *thres);

/**
 * @brief Set channel termination resistor (50 Ohms)
 *
 * @param b - pointer to struct tdc_board
 * @param config - value to enable the channels. The value is combination of the CHAN0, CHAN1, CHAN2, CHAN3 and CHAN4 enumeration values.
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_set_channels_term(struct tdc_board *b, uint32_t config);

/**
 * @brief Get channel termination resistor (50 Ohms)
 *
 * @param b - pointer to struct tdc_board
 * @param config - value to enable the channels. The value is combination of the CHAN0, CHAN1, CHAN2, CHAN3 and CHAN4 enumeration values.
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_get_channels_term(struct tdc_board *b, uint32_t *config);

/**
 * @brief Enable all channels to acquire
 *
 * It is needed to execute this function before calling tdc_start_acquisition().
 *
 * @param b - pointer to struct tdc_board
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_activate_channels(struct tdc_board *b);

/**
 * @brief Disable all channels to acquire
 *
 * @param b - pointer to struct tdc_board
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_deactivate_channels(struct tdc_board *b);

/**
 * @brief Get circular buffer pointer value.
 *
 * @param b - pointer to struct tdc_board
 * @param ptr - circular buffer pointer value with dacapo register included.
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_get_circular_buffer_pointer(struct tdc_board *b, uint32_t *ptr);

/**
 * @brief Clear Dacapo register.
 *
 * @param b - pointer to struct tdc_board
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_clear_dacapo_flag(struct tdc_board *b);

/**
 * @brief Read events
 *
 * @param b - pointer to struct tdc_board
 * @param chan - chan number, using the CHAN0, CHAN1, CHAN2, CHAN3 and CHAN4 enumeration.
 * @param t - buffer
 * @param n - number of events to read.
 * @param flags - flags: 0 (blocking read) or O_NONBLOCK (non blocking read).
 *
 * @return >0 - on success, device file descriptor number
 * @return <0 - if failure
 *
 */
extern int tdc_read(struct tdc_board *b, int chan, struct tdc_time *t,
		    int n, int flags);
#ifdef __cplusplus
}
#endif

#endif
