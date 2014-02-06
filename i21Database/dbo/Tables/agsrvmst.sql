CREATE TABLE [dbo].[agsrvmst] (
    [agsrv_srv_no]      TINYINT        NOT NULL,
    [agsrv_desc]        CHAR (20)      NULL,
    [agsrv_pct]         DECIMAL (5, 3) NULL,
    [agsrv_user_id]     CHAR (16)      NULL,
    [agsrv_user_rev_dt] INT            NULL,
    [A4GLIdentity]      NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agsrvmst] PRIMARY KEY NONCLUSTERED ([agsrv_srv_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagsrvmst0]
    ON [dbo].[agsrvmst]([agsrv_srv_no] ASC);

