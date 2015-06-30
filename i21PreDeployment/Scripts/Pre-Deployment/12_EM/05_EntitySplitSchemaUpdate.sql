PRINT '*** Check Entity Split ***' 
IF NOT EXISTS( SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntitySplitDetail' )
BEGIN
	EXEC( '
		CREATE TABLE [dbo].[tblEntitySplit]
		(
			[intSplitId]          INT           NOT NULL,
			[intEntityId]		  INT           NOT NULL,
			[strSplitNumber]      NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
			[strRecordType]       NVARCHAR (20) COLLATE Latin1_General_CI_AS NULL,
			[strAgExemptionClass] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
			[strDescription]      NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
			[dblAcres]            NUMERIC(18, 6),
			[intConcurrencyId]    INT           NOT NULL
		)
	')
	PRINT '*** Check Entity Split Detail ***'
	IF NOT EXISTS( SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntitySplitDetail' )
	BEGIN
		EXEC('
				CREATE TABLE [dbo].[tblEntitySplitDetail]
				(
					[intSplitDetailId] INT			   NOT NULL,
					[intSplitId]       INT             NOT NULL,
					[intEntityId]      INT             NULL,
					[dblSplitPercent]  NUMERIC (18, 6) NULL,
					[strOption]        NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
					[intConcurrencyId] INT             NOT NULL
				)
		')
	END
	PRINT '***  Move the data Entity Split and Details  ***'
	EXEC('
		DELETE FROM tblEntitySplit
		DELETE FROM tblEntitySplitDetail

		INSERT INTO tblEntitySplit (
			intSplitId,		intEntityId,			strSplitNumber,		strRecordType,		strAgExemptionClass,		strDescription,		dblAcres,		intConcurrencyId 
		)
		SELECT 
			intSplitId,		intEntityCustomerId,	strSplitNumber,		strRecordType,		strAgExemptionClass,		strDescription,		dblAcres,		intConcurrencyId
		FROM tblARCustomerSplit


		INSERT INTO tblEntitySplitDetail(
			intSplitDetailId,		intSplitId,		intEntityId,		dblSplitPercent,	strOption,		intConcurrencyId
		)
		SELECT 
			intSplitDetailId,		intSplitId,		intEntityId,		dblSplitPercent,	strOption,		intConcurrencyId
		FROM tblARCustomerSplitDetail
	')
END 