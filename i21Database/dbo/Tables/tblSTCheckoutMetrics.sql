CREATE TABLE [dbo].[tblSTCheckoutMetrics] (
    [intCheckoutMetricsId]										INT				IDENTITY (1, 1)					NOT NULL,
    [intCheckoutId]												INT												NOT NULL,
    [strMetricsDescription]										NVARCHAR (50)	COLLATE Latin1_General_CI_AS	NOT NULL,
	[dblAmount]													DECIMAL  (18, 6)									NULL,
	[intMetricItemId]											INT												NOT NULL, 
	[intOffsetItemId]											INT												NOT NULL,  
    [intRegisterImportFieldId]									INT												NOT NULL,  
	[intDepartmentId] 											INT 												NULL,
    [intConcurrencyId]											INT												NOT NULL,             
    CONSTRAINT [PK_tblSTCheckoutMetrics_intCheckoutMetricsId]						PRIMARY KEY CLUSTERED		([intCheckoutMetricsId]),
	CONSTRAINT [AK_tblSTCheckoutMetrics_intCheckoutId_strMetricsDescription]		UNIQUE	NONCLUSTERED		([intCheckoutId],[strMetricsDescription]),
    CONSTRAINT [FK_tblSTCheckoutMetrics_tblSTCheckoutHeader]						FOREIGN KEY					([intCheckoutId])			REFERENCES [dbo].[tblSTCheckoutHeader] ([intCheckoutId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSTCheckoutMetrics_tblICCategory]								FOREIGN KEY					([intDepartmentId])			REFERENCES [tblICCategory] ([intCategoryId]),
	CONSTRAINT [FK_tblSTCheckoutMetrics_tblICItemMetrics]							FOREIGN KEY					([intMetricItemId])			REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblSTCheckoutMetrics_tblICItemOffset]							FOREIGN KEY					([intOffsetItemId])			REFERENCES [tblICItem]([intItemId])
);

 -- intRegisterImportFieldId
 -- 1 = Customer Count
 -- 2 = Manual
 -- 3 = No Sales

-- DROP TABLE [dbo].[tblSTCheckoutMetrics]