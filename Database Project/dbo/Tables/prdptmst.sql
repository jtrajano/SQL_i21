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


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prdptmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prdptmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prdptmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prdptmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[prdptmst] TO PUBLIC
    AS [dbo];

