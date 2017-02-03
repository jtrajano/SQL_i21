
IF EXISTS (select top 1 1 from sys.procedures where name = 'uspARImportDefaultGLAccounts')
	DROP PROCEDURE uspARImportDefaultGLAccounts
GO

CREATE PROCEDURE uspARImportDefaultGLAccounts

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ysnAG BIT = 0
	DECLARE @ysnPT BIT = 0

	SELECT TOP 1 @ysnAG = CASE WHEN ISNULL(coctl_ag, '') = 'Y' THEN 1 ELSE 0 END
			   , @ysnPT = CASE WHEN ISNULL(coctl_pt, '') = 'Y' THEN 1 ELSE 0 END 
	FROM coctlmst	

	DECLARE @AR_Account NVARCHAR(100) 
	DECLARE @AR_Discount NVARCHAR(100)
	DECLARE @AR_WriteOff NVARCHAR(100)
	DECLARE @AR_ServiceCharge NVARCHAR(100)
	DECLARE @AR_SrvChrgCalc CHAR(1)

	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'aglocmst')
	BEGIN

		SET @AR_Account = (SELECT agcgl_ar FROM agctlmst where agctl_key = 3)
		SET @AR_Discount = (SELECT TOP 1 agloc_disc_taken FROM aglocmst)
		SET @AR_WriteOff = (SELECT TOP 1 agloc_write_off FROM aglocmst)
		SET @AR_ServiceCharge  = (SELECT TOP 1 agloc_srvchr FROM aglocmst)
		SET @AR_SrvChrgCalc = 'C'

	END

	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptmglmst')
	BEGIN

		SET @AR_Account = (select ptmgl_ar from ptmglmst)
		SET @AR_Discount = (select ptmgl_disc_taken from ptmglmst)
		SET @AR_WriteOff = (select ptmgl_write_off from ptmglmst)
		SET @AR_ServiceCharge  = (select ptmgl_fin_chgs from ptmglmst)
		SET @AR_SrvChrgCalc = (select pt3cf_serv_chrg_per from ptctlmst where ptctl_key = 3)

	END

	--SETUP AR ACCOUNT
	DECLARE @Primarycode NVARCHAR(100)
	DECLARE @AccountCategory NVARCHAR(100)
	SET @Primarycode = (select SUBSTRING(@AR_Account, 1, CHARINDEX('.', @AR_Account)-1)) -- enter Primary code here
	SET @AccountCategory ='AR Account' -- enter the Category
	UPDATE A
	SET A.intAccountCategoryId = ( SELECT intAccountCategoryId
	FROM tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategory)
	FROM tblGLAccountSegment A
	INNER JOIN tblGLAccountSegmentMapping B ON A.intAccountSegmentId = B.intAccountSegmentId
	INNER JOIN tblGLAccount C ON C.intAccountId = B.intAccountId
	WHERE A.strCode = @Primarycode
	AND A.intAccountStructureId IN( SELECT intAccountStructureId
	FROM tblGLAccountStructure
	WHERE strType = 'Primary' )
	-- To verify the change in Segment Screen
	SELECT A.strCode,
	D.strAccountCategory,
	C.strAccountId
	FROM tblGLAccountSegment A
	INNER JOIN tblGLAccountSegmentMapping B ON A.intAccountSegmentId = B.intAccountSegmentId
	INNER JOIN tblGLAccount C ON C.intAccountId = B.intAccountId
	INNER JOIN tblGLAccountCategory D ON D.intAccountCategoryId = A.intAccountCategoryId
	WHERE A.strCode = @Primarycode
	AND A.intAccountStructureId IN(
	SELECT intAccountStructureId
	FROM tblGLAccountStructure
	WHERE strType = 'Primary' )

	--SETUP AR DISCOUNT ACCOUNT
	SET @Primarycode = (select SUBSTRING(@AR_Discount, 1, CHARINDEX('.', @AR_Discount)-1))-- enter Primary code here
	SET @AccountCategory ='Sales Discount' -- enter the Category
	UPDATE A
	SET A.intAccountCategoryId = ( SELECT intAccountCategoryId
	FROM tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategory)
	FROM tblGLAccountSegment A
	INNER JOIN tblGLAccountSegmentMapping B ON A.intAccountSegmentId = B.intAccountSegmentId
	INNER JOIN tblGLAccount C ON C.intAccountId = B.intAccountId
	WHERE A.strCode = @Primarycode
	AND A.intAccountStructureId IN( SELECT intAccountStructureId
	FROM tblGLAccountStructure
	WHERE strType = 'Primary' )
	-- To verify the change in Segment Screen
	SELECT A.strCode,
	D.strAccountCategory,
	C.strAccountId
	FROM tblGLAccountSegment A
	INNER JOIN tblGLAccountSegmentMapping B ON A.intAccountSegmentId = B.intAccountSegmentId
	INNER JOIN tblGLAccount C ON C.intAccountId = B.intAccountId
	INNER JOIN tblGLAccountCategory D ON D.intAccountCategoryId = A.intAccountCategoryId
	WHERE A.strCode = @Primarycode
	AND A.intAccountStructureId IN(
	SELECT intAccountStructureId
	FROM tblGLAccountStructure
	WHERE strType = 'Primary' )

	--SETUP AR WRITTE OFF ACCOUNT
	SET @Primarycode = (select SUBSTRING(@AR_WriteOff, 1, CHARINDEX('.', @AR_WriteOff)-1)) -- enter Primary code here
	SET @AccountCategory ='Write Off' -- enter the Category
	UPDATE A
	SET A.intAccountCategoryId = ( SELECT intAccountCategoryId
	FROM tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategory)
	FROM tblGLAccountSegment A
	INNER JOIN tblGLAccountSegmentMapping B ON A.intAccountSegmentId = B.intAccountSegmentId
	INNER JOIN tblGLAccount C ON C.intAccountId = B.intAccountId
	WHERE A.strCode = @Primarycode
	AND A.intAccountStructureId IN( SELECT intAccountStructureId
	FROM tblGLAccountStructure
	WHERE strType = 'Primary' )
	-- To verify the change in Segment Screen
	SELECT A.strCode,
	D.strAccountCategory,
	C.strAccountId
	FROM tblGLAccountSegment A
	INNER JOIN tblGLAccountSegmentMapping B ON A.intAccountSegmentId = B.intAccountSegmentId
	INNER JOIN tblGLAccount C ON C.intAccountId = B.intAccountId
	INNER JOIN tblGLAccountCategory D ON D.intAccountCategoryId = A.intAccountCategoryId
	WHERE A.strCode = @Primarycode
	AND A.intAccountStructureId IN(
	SELECT intAccountStructureId
	FROM tblGLAccountStructure
	WHERE strType = 'Primary' )

	--SETUP AR SERVICE CHARGE ACCOUNT
	SET @Primarycode = (select SUBSTRING(@AR_ServiceCharge, 1, CHARINDEX('.', @AR_ServiceCharge  )-1)) -- enter Primary code here
	SET @AccountCategory ='Service Charges' -- enter the Category
	UPDATE A
	SET A.intAccountCategoryId = ( SELECT intAccountCategoryId
	FROM tblGLAccountCategory
	WHERE strAccountCategory = @AccountCategory)
	FROM tblGLAccountSegment A
	INNER JOIN tblGLAccountSegmentMapping B ON A.intAccountSegmentId = B.intAccountSegmentId
	INNER JOIN tblGLAccount C ON C.intAccountId = B.intAccountId
	WHERE A.strCode = @Primarycode
	AND A.intAccountStructureId IN( SELECT intAccountStructureId
	FROM tblGLAccountStructure
	WHERE strType = 'Primary' )
	-- To verify the change in Segment Screen
	SELECT A.strCode,
	D.strAccountCategory,
	C.strAccountId
	FROM tblGLAccountSegment A
	INNER JOIN tblGLAccountSegmentMapping B ON A.intAccountSegmentId = B.intAccountSegmentId
	INNER JOIN tblGLAccount C ON C.intAccountId = B.intAccountId
	INNER JOIN tblGLAccountCategory D ON D.intAccountCategoryId = A.intAccountCategoryId
	WHERE A.strCode = @Primarycode
	AND A.intAccountStructureId IN(
	SELECT intAccountStructureId
	FROM tblGLAccountStructure
	WHERE strType = 'Primary' )

	INSERT INTO [dbo].[tblARCompanyPreference]
			   ([intARAccountId]
			   ,[intDiscountAccountId]
			   ,[intWriteOffAccountId]
			   ,[intServiceChargeAccountId]
			   ,[strServiceChargeCalculation]
			   ,[intConcurrencyId])
		 VALUES
				((select intCrossReferenceId from tblGLCOACrossReference where strExternalId = @AR_Account)
			   ,(select intCrossReferenceId from tblGLCOACrossReference where strExternalId = @AR_Discount)
			   ,(select intCrossReferenceId from tblGLCOACrossReference where strExternalId = @AR_WriteOff)
			   ,(select intCrossReferenceId from tblGLCOACrossReference where strExternalId = @AR_ServiceCharge)
			   ,(CASE WHEN @AR_SrvChrgCalc = 'I' THEN 'By Invoice' ELSE 'By Customer Balance' END)
			   ,1)

END
GO
