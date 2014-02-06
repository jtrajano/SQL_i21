CREATE TABLE [dbo].[prdptmst] (
    [prdpt_dept_cd]       CHAR (4)    NOT NULL,
    [prdpt_desc]          CHAR (25)   NULL,
    [prdpt_profit_center] INT         NULL,
    [prdpt_user_id]       CHAR (16)   NULL,
    [prdpt_user_rev_dt]   INT         NULL,
    [A4GLIdentity]        NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prdptmst] PRIMARY KEY NONCLUSTERED ([prdpt_dept_cd] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iprdptmst0]
    ON [dbo].[prdptmst]([prdpt_dept_cd] ASC);

