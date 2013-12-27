CREATE TABLE [dbo].[prclkmst] (
    [prclk_emp]         CHAR (10)      NOT NULL,
    [prclk_seq]         TINYINT        NOT NULL,
    [prclk_date_in]     INT            NULL,
    [prclk_time_in]     DECIMAL (4, 2) NULL,
    [prclk_date_out]    INT            NULL,
    [prclk_time_out]    DECIMAL (4, 2) NULL,
    [prclk_dept]        CHAR (4)       NULL,
    [prclk_user_id]     CHAR (16)      NULL,
    [prclk_user_rev_dt] INT            NULL,
    [A4GLIdentity]      NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prclkmst] PRIMARY KEY NONCLUSTERED ([prclk_emp] ASC, [prclk_seq] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iprclkmst0]
    ON [dbo].[prclkmst]([prclk_emp] ASC, [prclk_seq] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prclkmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prclkmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prclkmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prclkmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[prclkmst] TO PUBLIC
    AS [dbo];

