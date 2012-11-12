#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/slab.h>

#include <linux/zio.h>
#include <linux/zio-sysfs.h>
#include <linux/zio-buffer.h>
#include <linux/zio-trigger.h>

#define ZTT_DEFAULT_BLOCK_SIZE 16

static ZIO_ATTR_DEFINE_STD(ZIO_TRG, ztt_std_attr) = {
	ZIO_ATTR(trig, ZIO_ATTR_TRIG_POST_SAMP, S_IRUGO | S_IWUGO,
		  0 /* no addr needed */, ZTT_DEFAULT_BLOCK_SIZE),
};

int ztt_conf_set(struct device *dev, struct zio_attribute *zattr,
		 uint32_t  usr_val)
{
	zattr->value = usr_val;
	return 0;
}

struct zio_sysfs_operations ztt_s_ops = {
	.conf_set = ztt_conf_set,
};

static struct zio_ti *ztt_create(struct zio_trigger_type *trig,
				 struct zio_cset *cset,
				 struct zio_control *ctrl, fmode_t flags)
{
	struct zio_ti *ti;

	ti = kzalloc(sizeof(*ti), GFP_KERNEL);
	if (!ti)
		return ERR_PTR(-ENOMEM);

	return ti;
}

static void ztt_destroy(struct zio_ti *ti)
{
	kfree(ti);
}

static const struct zio_trigger_operations ztt_trigger_ops = {
	.create = ztt_create,
	.destroy = ztt_destroy,
};

static struct zio_trigger_type ztt_trigger = {
	.owner = THIS_MODULE,
	.zattr_set = {
		.std_zattr = ztt_std_attr,
	},
	.s_op = &ztt_s_ops,
	.t_op = &ztt_trigger_ops,
};

static int zio_trig_tdc_init(void)
{
	return zio_register_trig(&ztt_trigger, "tdc");
}

static void zio_trig_tdc_exit(void)
{
	zio_unregister_trig(&ztt_trigger);
}

module_init(zio_trig_tdc_init);
module_exit(zio_trig_tdc_exit);
MODULE_LICENSE("GPL");
