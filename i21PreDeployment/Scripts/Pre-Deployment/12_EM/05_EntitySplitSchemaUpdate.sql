PRINT '*** Check Entity Split ***' 
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerSplit')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerSplitDetail')
BEGIN
		IF NOT EXISTS( SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntitySplitDetail' )
		BEGIN
			EXEC( '
				CREATE TABLE [dbo].[tblEMEntitySplit]
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
			IF NOT EXISTS( SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntitySplitDetail' )
			BEGIN
				EXEC('
						CREATE TABLE [dbo].[tblEMEntitySplitDetail]
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
			IF EXISTS  (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerSplit'  and [COLUMN_NAME] = 'intEntityCustomerId' )
			BEGIN
				EXEC('
					DELETE FROM tblEMEntitySplit
					DELETE FROM tblEMEntitySplitDetail

					INSERT INTO tblEMEntitySplit (
						intSplitId,		intEntityId,			strSplitNumber,		strRecordType,		strAgExemptionClass,		strDescription,		dblAcres,		intConcurrencyId 
					)
					SELECT 
						intSplitId,		intEntityCustomerId,	strSplitNumber,		strRecordType,		strAgExemptionClass,		strDescription,		dblAcres,		intConcurrencyId
					FROM tblARCustomerSplit


					INSERT INTO tblEMEntitySplitDetail(
						intSplitDetailId,		intSplitId,		intEntityId,		dblSplitPercent,	strOption,		intConcurrencyId
					)
					SELECT 
						intSplitDetailId,		intSplitId,		intEntityId,		dblSplitPercent,	strOption,		intConcurrencyId
					FROM tblARCustomerSplitDetail
				')
			END 
			ELSE			
			BEGIN
				EXEC('
					DELETE FROM tblEMEntitySplit
					DELETE FROM tblEMEntitySplitDetail

					INSERT INTO tblEMEntitySplit (
						intSplitId,		intEntityId,			strSplitNumber,		strRecordType,		strAgExemptionClass,		strDescription,		dblAcres,		intConcurrencyId 
					)
					SELECT 
						intSplitId,		intCustomerId,			strSplitNumber,		strRecordType,		strAgExemptionClass,		strDescription,		dblAcres,		intConcurrencyId
					FROM tblARCustomerSplit


					INSERT INTO tblEMEntitySplitDetail(
						intSplitDetailId,		intSplitId,		intEntityId,		dblSplitPercent,	strOption,		intConcurrencyId
					)
					SELECT 
						intSplitDetailId,		intSplitId,		intEntityId,		dblSplitPercent,	strOption,		intConcurrencyId
					FROM tblARCustomerSplitDetail
				')
			END
			
		END 
END
