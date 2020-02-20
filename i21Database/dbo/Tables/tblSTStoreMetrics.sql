CREATE TABLE [dbo].[tblSTStoreMetrics]
(
	[intStoreMetricsId]															INT						NOT NULL								IDENTITY, 
    [intStoreId]																INT						NOT NULL, 
    [strMetricsDescription]														NVARCHAR(50)			COLLATE Latin1_General_CI_AS NOT NULL, 
	[intMetricItemId]															INT						NOT NULL, 
	[intOffsetItemId]															INT						NOT NULL,  
    [intRegisterImportFieldId]													INT						NOT NULL,   
    [intConcurrencyId]															INT						NOT NULL, 
    CONSTRAINT [PK_tblSTStoreMetrics]											PRIMARY KEY CLUSTERED	([intStoreMetricsId]), 
    CONSTRAINT [AK_tblSTStoreMetrics_intStoreId_ImportField_MetricItemId_OffsetItemId]			UNIQUE	NONCLUSTERED	([intStoreId],[intRegisterImportFieldId],[intMetricItemId],[intOffsetItemId]),
	CONSTRAINT [FK_tblSTStoreMetrics_tblSTStore]								FOREIGN KEY				([intStoreId])							REFERENCES [tblSTStore]([intStoreId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSTStoreMetrics_tblICItemMetrics]							FOREIGN KEY				([intMetricItemId])						REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblSTStoreMetrics_tblICItemOffset]							FOREIGN KEY				([intOffsetItemId])						REFERENCES [tblICItem]([intItemId])

 );

 -- intRegisterImportFieldId
 -- 1 = Customer Count
 -- 2 = Manual
 -- 3 = No Sales

 -- DROP TABLE [dbo].[tblSTStoreMetrics]