
;WITH p AS (SELECT user_id
				, ISNULL(SUM(CASE WHEN spl.sent_at_EST >= DATEADD(HOUR, -24, GETDATE()) THEN 1 ELSE 0 END), 0) AS '24HourProfileViews'
				, ISNULL(SUM(CASE WHEN spl.sent_at_EST >= DATEADD(DAY, -30, GETDATE()) THEN 1 ELSE 0 END), 0) AS '30DayProfileViews'
			FROM Reports.dbo.TableauSegmentStorePageLoaded AS spl WITH (NOLOCK)
			GROUP BY user_id)

, s AS (SELECT ss.UserID
				, ISNULL(SUM(CASE WHEN ss.SearchdateEst >= DATEADD(HOUR, -24, GETDATE()) THEN 1 ELSE 0 END), 0) AS '24HourSearches'
				, ISNULL(SUM(CASE WHEN ss.SearchdateEst >= DATEADD(HOUR, -24, GETDATE()) AND ss.SearchType IN ('Category', 'CategorySearch') THEN 1 ELSE 0 END), 0) AS '24HourCategorySearches'
				, ISNULL(SUM(CASE WHEN ss.SearchdateEst >= DATEADD(HOUR, -24, GETDATE()) AND ss.SearchType = 'Keyword' THEN 1 ELSE 0 END), 0) AS '24HourKeywordSearches'
				, ISNULL(SUM(CASE WHEN ss.SearchdateEst >= DATEADD(DAY, -30, GETDATE()) THEN 1 ELSE 0 END), 0) AS '30DaySearches'
				, ISNULL(SUM(CASE WHEN ss.SearchdateEst >= DATEADD(DAY, -30, GETDATE()) AND ss.SearchType IN ('Category', 'CategorySearch') THEN 1 ELSE 0 END), 0) AS '30DayCategorySearches'
				, ISNULL(SUM(CASE WHEN ss.SearchdateEst >= DATEADD(DAY, -30, GETDATE()) AND ss.SearchType = 'Keyword' THEN 1 ELSE 0 END), 0) AS '30DayKeywordSearches'
			FROM Reports.dbo.SegmentSearches AS ss WITH (NOLOCK)
			GROUP BY ss.UserID)

SELECT TOP 100 s.UserID
	, s.[24HourSearches]
	, s.[24HourCategorySearches]
	, s.[24HourKeywordSearches]
	, s.[30DaySearches]
	, s.[30DayCategorySearches]
	, s.[30DayKeywordSearches]
	, p.[24HourProfileViews]
	, p.[30DayProfileViews]
FROM s WITH (NOLOCK)
LEFT JOIN p WITH (NOLOCK) ON s.UserID = p.user_id
ORDER BY s.[24HourSearches] DESC 

/* QUERIES TO CHECK RESULTS OF MASTER QUERY 

SELECT ss.UserID 
	, SUM(ss.COUNT) AS counts  
FROM Reports.dbo.SegmentSearches AS ss WITH (NOLOCK)
WHERE ss.SearchdateEst >= DATEADD(DAY, -30, GETDATE())
	AND ss.SearchType IN ('Category', 'CategorySearch')
	AND ss.UserID IN ('41339427', '50519359', '49691075')
GROUP BY ss.UserID
ORDER BY counts DESC

SELECT ss.UserID
	, SUM(ss.COUNT) AS counts  
FROM Reports.dbo.SegmentSearches AS ss WITH (NOLOCK)
WHERE ss.SearchdateEst >= DATEADD(hour, -24, GETDATE())
	AND ss.SearchType IN ('keyword')
	AND ss.UserID IN ('41339427', '50519359', '49691075')
GROUP BY ss.UserID

SELECT spl.user_id
	, COUNT(*) 
FROM Reports.dbo.TableauSegmentStorePageLoaded AS spl WITH (NOLOCK)
WHERE spl.sent_at_EST >= DATEADD(DAY, -30, GETDATE())
	AND spl.user_id IN (41339427, 50519359, 49691075)
GROUP BY spl.user_id

*/

/* original query provided to Erin Wyne on 9/6/2016 to generate top 100 excessive searchers

SELECT TOP 100 ds.UserID
	, ds.GTType 
	, ds.TestUser
	, ds.FirstName
	, ds.LastName
	, ds.Email
	, SUM(ds.COUNT) AS UniqueSearchCount
	, SUM(CASE WHEN ds.SearchType IN ('Category', 'CategorySearch') THEN 1 ELSE 0 END) AS UniqueCategorySearches
	, SUM(CASE WHEN ds.SearchType = 'keyword' THEN 1 ELSE 0 END) AS UniqueKeywordSearches
FROM (SELECT CAST(ss.SearchdateEst AS DATE) AS SearchDate
	, ss.UserID
	, ISNULL(ttype.GreenThunderTierType, 'NoTierType') AS GTType
	, t.TestUser
	, t.FirstName
	, t.LastName
	, t.Email
	, ss.SearchType
	, ss.Category
	, ss.Keyword
	, ss.Platform
	, mz.Zone AS AdZone
	, ss.COUNT 
	, AVG(ss.AdvertisersOnPage) AS AvgAdvertisersOnPage
	, AVG(ss.TotalResults) AS AvgTotalResults
	, AVG(TotalResults - AdvertisersOnPage) AS AvgNonAdvertisers
FROM Reports.dbo.SegmentSearches AS ss WITH (NOLOCK)
LEFT JOIN angie.dbo.tblMarketZones AS mz WITH (NOLOCK) 
	ON ss.location_info_advertising_zone = mz.ZoneID
LEFT JOIN Angie.dbo.MemberMembershipTier AS tier WITH (NOLOCK)
	ON ss.MemberID = tier.MemberId 
LEFT JOIN Angie.dbo.GreenThunderMembershipTier AS ttype WITH (NOLOCK)
	ON tier.MembershipTierId = ttype.GreenThunderMembershipTierId
LEFT JOIN [MSSQL1-PRODLAKE].AngiesList.dbo.t_User AS t 
	ON ss.UserID = t.UserId
WHERE ss.UserID IS NOT NULL
	AND ss.location_info_advertising_zone IS NOT NULL 
	AND CAST(ss.SearchdateEst AS DATE) >= CAST(DATEADD(DAY, -30, GETDATE()) AS DATE)
GROUP BY CAST(ss.SearchdateEst AS DATE)
	, ss.UserID
	, ttype.GreenThunderTierType
	, t.TestUser
	, t.FirstName
	, t.LastName
	, t.Email
	, ss.SearchType
	, ss.Category
	, ss.Keyword
	, ss.Platform
	, mz.Zone 
	, ss.COUNT) AS ds 
GROUP BY ds.UserID
	, ds.GTType
	, ds.TestUser
	, ds.FirstName
	, ds.LastName
	, ds.Email
ORDER BY SUM(ds.COUNT) DESC*/


