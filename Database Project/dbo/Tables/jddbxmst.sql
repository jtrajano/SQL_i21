CREATE TABLE [dbo].[jddbxmst] (
    [jddbx_itm_no]      CHAR (10)   NOT NULL,
    [jddbx_loc_no]      CHAR (3)    NOT NULL,
    [jddbx_class]       CHAR (3)    NOT NULL,
    [jddbx_bill_code]   INT         NOT NULL,
    [jddbx_timestamp]   CHAR (25)   NULL,
    [jddbx_user_id]     CHAR (16)   NULL,
    [jddbx_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_jddbxmst] PRIMARY KEY NONCLUSTERED ([jddbx_itm_no] ASC, [jddbx_loc_no] ASC, [jddbx_class] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Ijddbxmst0]
    ON [dbo].[jddbxmst]([jddbx_itm_no] ASC, [jddbx_loc_no] ASC, [jddbx_class] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijddbxmst1]
    ON [dbo].[jddbxmst]([jddbx_itm_no] ASC, [jddbx_loc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijddbxmst2]
    ON [dbo].[jddbxmst]([jddbx_class] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijddbxmst3]
    ON [dbo].[jddbxmst]([jddbx_bill_code] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[jddbxmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[jddbxmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[jddbxmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[jddbxmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[jddbxmst] TO PUBLIC
    AS [dbo];

