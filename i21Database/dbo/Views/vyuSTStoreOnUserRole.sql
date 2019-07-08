CREATE VIEW [dbo].[vyuSTStoreOnUserRole]
AS
SELECT 
		CAST(ROW_NUMBER() over(order by intEntityUserSecurityId desc) AS INT) intId,
		intEntityUserSecurityId,
		intStoreId,
		intStoreNo,
		strDescription		
		FROM tblSTStore
		INNER JOIN (
			SELECT  intEntityUserSecurityId
					,intEntityId
					,intUserRoleId
					,intMultiCompanyId
					,intCompanyLocationId
					,tblSMUserRole.strRoleType
					,tblSMUserRole.ysnAdmin
			FROM tblSMUserSecurityCompanyLocationRolePermission 
			INNER JOIN tblSMUserRole 
			ON tblSMUserRole.intUserRoleID = tblSMUserSecurityCompanyLocationRolePermission.intUserRoleId
		) as tblSMUserRoleLocation
		ON tblSTStore.intCompanyLocationId = tblSMUserRoleLocation.intCompanyLocationId
		OR ysnAdmin =1 
		GROUP BY 
		intEntityUserSecurityId,
		intStoreId,
		intStoreNo,
		strDescription	