CREATE TABLE [dbo].[galshmst] (
    [galsh_cus_no]        CHAR (10)   NOT NULL,
    [galsh_ship_to]       CHAR (4)    NOT NULL,
    [galsh_name]          CHAR (50)   NULL,
    [galsh_addr]          CHAR (30)   NULL,
    [galsh_addr2]         CHAR (30)   NULL,
    [galsh_city]          CHAR (20)   NULL,
    [galsh_state]         CHAR (2)    NULL,
    [galsh_zip]           CHAR (10)   NULL,
    [galsh_phone]         CHAR (15)   NULL,
    [galsh_phone_ext]     CHAR (4)    NULL,
    [galsh_contact]       CHAR (20)   NULL,
    [galsh_comments]      CHAR (30)   NULL,
    [galsh_def_equip_typ] TINYINT     NULL,
    [galsh_pp_ton_tax_yn] CHAR (1)    NULL,
    [galsh_user_id]       CHAR (16)   NULL,
    [galsh_user_rev_dt]   INT         NULL,
    [A4GLIdentity]        NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_galshmst] PRIMARY KEY NONCLUSTERED ([galsh_cus_no] ASC, [galsh_ship_to] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igalshmst0]
    ON [dbo].[galshmst]([galsh_cus_no] ASC, [galsh_ship_to] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[galshmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[galshmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[galshmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[galshmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[galshmst] TO PUBLIC
    AS [dbo];

