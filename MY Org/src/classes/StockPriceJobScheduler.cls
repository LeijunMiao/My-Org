global class StockPriceJobScheduler
	{
	global void StockPriceJobScheduler() {}
	public static void start()
	{
	system.schedule('One Time Pro', '0 0 13 * * ?',new scheduledBatchable());
	}
	}