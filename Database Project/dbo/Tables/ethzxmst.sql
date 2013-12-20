CREATE TABLE [dbo].[ethzxmst] (
    [ethzx_epa]         CHAR (2)    NOT NULL,
    [ethzx_itm]         CHAR (15)   NOT NULL,
    [ethzx_date_calc]   INT         NOT NULL,
    [ethzx_time_calc]   INT         NOT NULL,
    [ethzx_last_rev_dt] INT         NULL,
    [ethzx_last_time]   INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ethzxmst] PRIMARY KEY NONCLUSTERED ([ethzx_epa] ASC, [ethzx_itm] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iethzxmst0]
    ON [dbo].[ethzxmst]([ethzx_epa] ASC, [ethzx_itm] ASC);


GO
CREATE NONCLUSTERED INDEX [Iethzxmst1]
    ON [dbo].[ethzxmst]([ethzx_itm] ASC);


GO
CREATE NONCLUSTERED INDEX [Iethzxmst2]
    ON [dbo].[ethzxmst]([ethzx_date_calc] ASC, [ethzx_time_calc] ASC);

