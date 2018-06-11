CREATE NONCLUSTERED INDEX [IX_tblGLDetail_ysnIsUnposted] ON [dbo].[tblGLDetail] 
(
	[ysnIsUnposted] ASC
)
INCLUDE ( [dtmDate],
[intAccountId]) WITH ( STATISTICS_NORECOMPUTE  = OFF,   IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
