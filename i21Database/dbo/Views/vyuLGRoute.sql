CREATE VIEW vyuLGRoute
AS
SELECT 
	 Rte.intRouteId
	,Rte.strRouteNumber
	,Rte.intSourceType
	,strSourceType = CASE WHEN Rte.intSourceType = 1 THEN 
							'LG Loads'
						ELSE
							CASE WHEN Rte.intSourceType = 2 THEN
								'TM Orders'
							ELSE
								''
							END
						END
	,Rte.intDriverEntityId
	,strDriver = Driver.strName
	,Rte.dtmDispatchedDate
	,Rte.dblTruckCapacity
	,Rte.strComments
	,Rte.intFromCompanyLocationId
	,Rte.intFromCompanyLocationSubLocationId
	,Rte.ysnPosted
	,Rte.dtmPostedDate
	,strFromAddress			= CASE WHEN IsNull(Rte.intFromCompanyLocationSubLocationId, 0) <> 0 THEN 
									SubCompLoc.strAddress 
								ELSE 
									CASE WHEN IsNull(Rte.intFromCompanyLocationId, 0) <> 0 THEN 
										CompLoc.strAddress
									ELSE
										''
									END
								END
	,strFromCity			= CASE WHEN IsNull(Rte.intFromCompanyLocationSubLocationId, 0) <> 0 THEN 
									SubCompLoc.strCity 
								ELSE 
									CASE WHEN IsNull(Rte.intFromCompanyLocationId, 0) <> 0 THEN 
										CompLoc.strCity
									ELSE
										''
									END
								END
	,strFromState			= CASE WHEN IsNull(Rte.intFromCompanyLocationSubLocationId, 0) <> 0 THEN 
									SubCompLoc.strState 
								ELSE 
									CASE WHEN IsNull(Rte.intFromCompanyLocationId, 0) <> 0 THEN 
										CompLoc.strStateProvince
									ELSE
										''
									END
								END
	,strFromZipCode			= CASE WHEN IsNull(Rte.intFromCompanyLocationSubLocationId, 0) <> 0 THEN 
									SubCompLoc.strZipCode 
								ELSE 
									CASE WHEN IsNull(Rte.intFromCompanyLocationId, 0) <> 0 THEN 
										CompLoc.strZipPostalCode
									ELSE
										''
									END
								END
	,strFromCountry			= CASE WHEN IsNull(Rte.intFromCompanyLocationSubLocationId, 0) <> 0 THEN 
									''
								ELSE 
									CASE WHEN IsNull(Rte.intFromCompanyLocationId, 0) <> 0 THEN 
										CompLoc.strCountry
									ELSE
										''
									END
								END
	,dblFromLatitude			= CASE WHEN IsNull(Rte.intFromCompanyLocationSubLocationId, 0) <> 0 THEN 
									SubCompLoc.dblLatitude 
								ELSE 
									CASE WHEN IsNull(Rte.intFromCompanyLocationId, 0) <> 0 THEN 
										CompLoc.dblLatitude
									ELSE
										0.0
									END
								END
	,dblFromLongitude			= CASE WHEN IsNull(Rte.intFromCompanyLocationSubLocationId, 0) <> 0 THEN 
									SubCompLoc.dblLongitude 
								ELSE 
									CASE WHEN IsNull(Rte.intFromCompanyLocationId, 0) <> 0 THEN 
										CompLoc.dblLongitude
									ELSE
										0.0
									END
								END
	,strFromLocation			= CASE WHEN IsNull(Rte.intFromCompanyLocationId, 0) <> 0 THEN 
										CompLoc.strLocationName
									ELSE
										''
									END
	,strFromSubLocation			= CASE WHEN IsNull(Rte.intFromCompanyLocationSubLocationId, 0) <> 0 THEN 
									SubCompLoc.strSubLocationName
								ELSE 
									''
								END
FROM tblLGRoute Rte
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = Rte.intDriverEntityId
LEFT JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = Rte.intFromCompanyLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubCompLoc ON SubCompLoc.intCompanyLocationSubLocationId = Rte.intFromCompanyLocationSubLocationId


