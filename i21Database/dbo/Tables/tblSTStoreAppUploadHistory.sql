CREATE TABLE [dbo].[tblSTStoreAppUploadHistory]
(
    [intStoreAppUploadHistoryId] INT				NOT NULL IDENTITY,
	[intStoreNo]				INT					NULL,
	[strLocalFolderPath]		NVARCHAR(500)		COLLATE Latin1_General_CI_AS NULL,				-- 'C:\Users\HZaragoza\Desktop\Register\Passport\Inbound'
	[strLocalFilename]			NVARCHAR(100)		COLLATE Latin1_General_CI_AS NULL,				-- Include the extension name 'FGM20180801102433.xml'
	[stri21FolderPath]			NVARCHAR(500)		COLLATE Latin1_General_CI_AS NULL,				-- 'C:\Users\HZaragoza\Desktop\Register\Passport\Inbound'
	[stri21ConvertedFilename]	NVARCHAR(100)		COLLATE Latin1_General_CI_AS NULL,				-- Converted Filename will be based on Shift Closed date 'Prefix+[yyyyMMddHHmmss]' ISM20180801102433.xml
	[strFilePrefix]				NVARCHAR(20)		COLLATE Latin1_General_CI_AS NULL,
	[dtmShiftCloseDate]			DATETIME			NULL,
	[dtmDateUploaded]			DATETIME			NULL,
	[ysnUploadSuccess]			BIT					DEFAULT CAST(0 AS BIT) NOT NULL,
	[strRemark]					NVARCHAR(1000)		COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]          INT					DEFAULT CAST(1 AS BIT) NOT NULL
    CONSTRAINT [PK_tblSTStoreAppUploadHistory] PRIMARY KEY CLUSTERED (
		[intStoreAppUploadHistoryId] ASC
	)
)