GO
	PRINT 'START OF CREATING [uspTMRecreateUpdateRouteSequenceSP] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateUpdateRouteSequenceSP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateUpdateRouteSequenceSP
GO


CREATE PROCEDURE uspTMRecreateUpdateRouteSequenceSP 
AS
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMUpdateRouteSequence]') AND type in (N'P', N'PC')) 
	BEGIN
		DROP PROCEDURE [uspTMUpdateRouteSequence]
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwslsmst') = 1 
	)
	BEGIN
		EXEC('
			CREATE PROCEDURE uspTMUpdateRouteSequence 
				@RouteOrder RouteOrdersTableType READONLY
			AS
			BEGIN


				--Update Driver
				UPDATE tblTMDispatch
					SET intDriverID = C.A4GLIdentity
				FROM @RouteOrder A
				INNER JOIN tblEMEntity B
					ON A.intDriverEntityId = B.intEntityId
				INNER JOIN vwslsmst C
					ON B.strEntityNo COLLATE Latin1_General_CI_AS = ISNULL(LTRIM(RTRIM(C.vwsls_slsmn_id)),'''') COLLATE Latin1_General_CI_AS
				WHERE tblTMDispatch.intDispatchID = A.intOrderId

				--Update Dispatch
				UPDATE tblTMDispatch
					SET intRouteId = A.intRouteId
						,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
						,strWillCallStatus = CASE WHEN A.intRouteId IS NULL THEN ''Generated'' ELSE ''Routed'' END
				FROM @RouteOrder A
				WHERE tblTMDispatch.intDispatchID = A.intOrderId

				---Update Site
				UPDATE tblTMSite
				SET dblLongitude = A.dblLongitude
					,dblLatitude =A.dblLatitude
					,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
				FROM ( 
					SELECT A.*
						,B.intSiteID
					FROM @RouteOrder A
					INNER JOIN tblTMDispatch B
						ON A.intOrderId = B.intDispatchID
				) A
				WHERE tblTMSite.intSiteID = A.intSiteID
					AND (ISNULL(tblTMSite.dblLongitude,0) = 0 OR ISNULL(tblTMSite.dblLatitude,0) = 0)


	
			END
		')
	END
	ELSE
	BEGIN
		NOORIGIN:
		EXEC('
			CREATE PROCEDURE uspTMUpdateRouteSequence 
				@RouteOrder RouteOrdersTableType READONLY
			AS
			BEGIN

				--Update Dispatch
				UPDATE tblTMDispatch
					SET intRouteId = A.intRouteId
						,intDriverID = A.[intDriverEntityId]
						,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
						,strWillCallStatus = CASE WHEN A.intRouteId IS NULL THEN ''Generated'' ELSE ''Routed'' END
				FROM @RouteOrder A
				WHERE tblTMDispatch.intDispatchID = A.intOrderId

				---Update Site
				UPDATE tblTMSite
				SET dblLongitude = A.dblLongitude
					,dblLatitude =A.dblLatitude
					,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
				FROM ( 
					SELECT A.*
						,B.intSiteID
					FROM @RouteOrder A
					INNER JOIN tblTMDispatch B
						ON A.intOrderId = B.intDispatchID
				) A
				WHERE tblTMSite.intSiteID = A.intSiteID
					AND (ISNULL(tblTMSite.dblLongitude,0) = 0 OR ISNULL(tblTMSite.dblLatitude,0) = 0)


	
			END
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateUpdateRouteSequenceSP] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateUpdateRouteSequenceSP] SP'
GO
	EXEC ('uspTMRecreateUpdateRouteSequenceSP')
GO
	PRINT 'END OF Execute [uspTMRecreateUpdateRouteSequenceSP] SP'
GO
