/****** Object:  Index [tblGLDetail_strTransactionId]    Script Date: 02/09/2020 1:53:33 PM ******/
CREATE NONCLUSTERED INDEX [IX_tblGLDetail_strTransactionId] ON [dbo].[tblGLDetail]
(
	[strTransactionId] ASC
)
INCLUDE (
    [ysnIsUnposted],
	[intAccountId])
    WITH (PAD_INDEX = OFF,
    STATISTICS_NORECOMPUTE = OFF,
    SORT_IN_TEMPDB = OFF,
    DROP_EXISTING = OFF,
    ONLINE = OFF,
    ALLOW_ROW_LOCKS = ON,
    ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
GO


