CREATE TABLE [dbo].[tblARPaymentIntegrationLog]
(
	[intIntegrationLogId]				INT NOT NULL  IDENTITY,
	[dtmDate]							DATETIME NOT NULL,
    [intEntityId]						INT NOT NULL,
	[intGroupingOption]					INT NOT NULL DEFAULT ((0)),
	[strErrorMessage]					NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,	
	[strBatchIdForNewPost]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intPostedNewCount]					INT NOT NULL DEFAULT ((0)),
	[strBatchIdForNewPostRecap]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intRecapNewCount]					INT NOT NULL DEFAULT ((0)),
	[strBatchIdForExistingPost]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intPostedExistingCount]			INT NOT NULL DEFAULT ((0)),
	[strBatchIdForExistingRecap]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intRecapPostExistingCount]			INT NOT NULL DEFAULT ((0)),
	[strBatchIdForExistingUnPost]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intUnPostedExistingCount]			INT NOT NULL DEFAULT ((0)),
	[strBatchIdForExistingUnPostRecap]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intRecapUnPostedExistingCount]		INT NOT NULL DEFAULT ((0)),
    [intConcurrencyId]					INT NOT NULL CONSTRAINT [DF_tblARPaymentIntegrationLog_intConcurrencyId] DEFAULT ((0)),
    CONSTRAINT [PK_tblARPaymentIntegrationLog_intIntegrationLogId] PRIMARY KEY CLUSTERED ([intIntegrationLogId] ASC)
)
