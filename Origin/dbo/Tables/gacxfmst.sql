CREATE TABLE [dbo].[gacxfmst] (
    [gacxf_card_cus_no]        CHAR (16)      NOT NULL,
    [gacxf_ag_cus_no]          CHAR (10)      NOT NULL,
    [gacxf_card_desc]          CHAR (30)      NULL,
    [gacxf_com_cd]             CHAR (3)       NULL,
    [gacxf_truck_id]           CHAR (16)      NULL,
    [gacxf_driver]             CHAR (12)      NULL,
    [gacxf_active_yn]          CHAR (1)       NULL,
    [gacxf_load_in_process_yn] CHAR (1)       NULL,
    [gacxf_in_out_auth_io]     CHAR (1)       NULL,
    [gacxf_ticket_no]          CHAR (10)      NULL,
    [gacxf_ag_itm_no]          CHAR (13)      NULL,
    [gacxf_comment]            CHAR (50)      NULL,
    [gacxf_pin_no]             CHAR (4)       NULL,
    [gacxf_prt_cnt]            CHAR (1)       NULL,
    [gacxf_multi_card_yn]      CHAR (1)       NULL,
    [gacxf_multi_com_cd_yn]    CHAR (1)       NULL,
    [gacxf_trkr_no]            CHAR (10)      NULL,
    [gacxf_trkr_un_rt]         DECIMAL (9, 5) NULL,
    [gacxf_xfr_elev_un_rt]     DECIMAL (9, 5) NULL,
    [gacxf_user_id]            CHAR (16)      NULL,
    [gacxf_user_rev_dt]        INT            NULL,
    [A4GLIdentity]             NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gacxfmst] PRIMARY KEY NONCLUSTERED ([gacxf_card_cus_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igacxfmst0]
    ON [dbo].[gacxfmst]([gacxf_card_cus_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Igacxfmst1]
    ON [dbo].[gacxfmst]([gacxf_ag_cus_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[gacxfmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gacxfmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gacxfmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gacxfmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gacxfmst] TO PUBLIC
    AS [dbo];

