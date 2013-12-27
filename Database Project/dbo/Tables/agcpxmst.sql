CREATE TABLE [dbo].[agcpxmst] (
    [agcpx_cus_no]      CHAR (10)   NOT NULL,
    [agcpx_itm_no]      CHAR (13)   NOT NULL,
    [agcpx_cus_product] CHAR (20)   NOT NULL,
    [agcpx_pic_note1]   CHAR (33)   NULL,
    [agcpx_pic_note2]   CHAR (33)   NULL,
    [agcpx_pic_note3]   CHAR (33)   NULL,
    [agcpx_user_id]     CHAR (16)   NULL,
    [agcpx_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agcpxmst] PRIMARY KEY NONCLUSTERED ([agcpx_cus_no] ASC, [agcpx_itm_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagcpxmst0]
    ON [dbo].[agcpxmst]([agcpx_cus_no] ASC, [agcpx_itm_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagcpxmst1]
    ON [dbo].[agcpxmst]([agcpx_cus_product] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agcpxmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agcpxmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agcpxmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agcpxmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agcpxmst] TO PUBLIC
    AS [dbo];

