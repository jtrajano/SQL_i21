CREATE TABLE [dbo].[awclxmst] (
    [awclx_category]     CHAR (2)    NOT NULL,
    [awclx_sub_category] CHAR (2)    NOT NULL,
    [awclx_class_1]      CHAR (3)    NULL,
    [awclx_class_2]      CHAR (3)    NULL,
    [awclx_class_3]      CHAR (3)    NULL,
    [awclx_class_4]      CHAR (3)    NULL,
    [awclx_class_5]      CHAR (3)    NULL,
    [awclx_class_6]      CHAR (3)    NULL,
    [awclx_class_7]      CHAR (3)    NULL,
    [awclx_class_8]      CHAR (3)    NULL,
    [awclx_class_9]      CHAR (3)    NULL,
    [awclx_class_10]     CHAR (3)    NULL,
    [awclx_user_id]      CHAR (16)   NULL,
    [awclx_user_rev_dt]  INT         NULL,
    [A4GLIdentity]       NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_awclxmst] PRIMARY KEY NONCLUSTERED ([awclx_category] ASC, [awclx_sub_category] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iawclxmst0]
    ON [dbo].[awclxmst]([awclx_category] ASC, [awclx_sub_category] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[awclxmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[awclxmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[awclxmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[awclxmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[awclxmst] TO PUBLIC
    AS [dbo];

