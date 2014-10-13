public with sharing class MS_MonthUtility 
{
	public static Map<Integer, String> MonthMap
	{
		get
		{
			if (MonthMap == null)
			{
				MonthMap = new Map<Integer, String>();
				MonthMap.put(1,'January');
				MonthMap.put(2,'February');
				MonthMap.put(3,'March');
				MonthMap.put(4,'April');
				MonthMap.put(5,'May');
				MonthMap.put(6,'June');
				MonthMap.put(7,'July');
				MonthMap.put(8,'August');
				MonthMap.put(9,'September');
				MonthMap.put(10,'October');
				MonthMap.put(11,'November');
				MonthMap.put(12,'December');
			}
			
			return MonthMap;	
		}
		
		set;
	}
}