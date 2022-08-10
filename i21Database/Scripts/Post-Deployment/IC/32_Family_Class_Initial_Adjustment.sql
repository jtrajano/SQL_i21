-- =============================================
-- Author:		<Author,,Jonathan Valenzuela>
-- Create date: <Create Date,, 08/10/2022>
-- Description:	<Description,, Initial Update of Family & Class on tblICItem - IC-10411>
-- =============================================

PRINT('/*******************  BEGIN UPDATING OF FAMILY & CLASS  *******************/')
GO

/* Check first if the script is already executed. */
IF (SELECT ISNULL(ysnInitialFamilyClassAdjustment, 0) FROM tblICCompanyPreference) <> 1
	BEGIN

		/* Start Updating Family and Class on tblICItem. */
		UPDATE A
		SET A.intStoreClassId = B.intClassId
		  , A.intStoreFamilyId = B.intFamilyId
		FROM tblICItem AS A
		OUTER APPLY (SELECT TOP 1 intClassId, intFamilyId 
					 FROM tblICItemLocation
					 WHERE intItemId = A.intItemId AND (intClassId IS NOT NULL OR intFamilyId IS NOT NULL )) AS B
		WHERE intItemId IN (SELECT intItemId
							FROM tblICItemLocation
							WHERE intClassId IS NOT NULL OR intFamilyId IS NOT NULL);

		/* Set initial Family and Class adjustment into true. */
		UPDATE tblICCompanyPreference
		SET	ysnInitialFamilyClassAdjustment = 1;
	END
GO
PRINT('/*******************  END UPDATING OF FAMILY & CLASS *******************/')
