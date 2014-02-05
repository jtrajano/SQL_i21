﻿CREATE TABLE [dbo].[slsitmst] (
    [slsit_site_id]               SMALLINT    NOT NULL,
    [slsit_name]                  CHAR (50)   NULL,
    [slsit_addr]                  CHAR (30)   NULL,
    [slsit_city]                  CHAR (20)   NULL,
    [slsit_state]                 CHAR (2)    NULL,
    [slsit_zip]                   CHAR (10)   NULL,
    [slsit_phone]                 CHAR (15)   NULL,
    [slsit_last_pack_sent]        SMALLINT    NULL,
    [slsit_last_pack_sent_rev_dt] INT         NULL,
    [slsit_last_pack_rcvd]        SMALLINT    NULL,
    [slsit_last_pack_rcvd_rev_dt] INT         NULL,
    [slsit_slsmn_id_1]            CHAR (3)    NULL,
    [slsit_slsmn_id_2]            CHAR (3)    NULL,
    [slsit_slsmn_id_3]            CHAR (3)    NULL,
    [slsit_slsmn_id_4]            CHAR (3)    NULL,
    [slsit_slsmn_id_5]            CHAR (3)    NULL,
    [slsit_slsmn_id_6]            CHAR (3)    NULL,
    [slsit_slsmn_id_7]            CHAR (3)    NULL,
    [slsit_slsmn_id_8]            CHAR (3)    NULL,
    [slsit_slsmn_id_9]            CHAR (3)    NULL,
    [slsit_slsmn_id_10]           CHAR (3)    NULL,
    [slsit_slsmn_id_11]           CHAR (3)    NULL,
    [slsit_slsmn_id_12]           CHAR (3)    NULL,
    [slsit_slsmn_id_13]           CHAR (3)    NULL,
    [slsit_slsmn_id_14]           CHAR (3)    NULL,
    [slsit_slsmn_id_15]           CHAR (3)    NULL,
    [slsit_slsmn_id_16]           CHAR (3)    NULL,
    [slsit_slsmn_id_17]           CHAR (3)    NULL,
    [slsit_slsmn_id_18]           CHAR (3)    NULL,
    [slsit_slsmn_id_19]           CHAR (3)    NULL,
    [slsit_slsmn_id_20]           CHAR (3)    NULL,
    [slsit_state_id_1]            CHAR (2)    NULL,
    [slsit_state_id_2]            CHAR (2)    NULL,
    [slsit_state_id_3]            CHAR (2)    NULL,
    [slsit_state_id_4]            CHAR (2)    NULL,
    [slsit_state_id_5]            CHAR (2)    NULL,
    [slsit_state_id_6]            CHAR (2)    NULL,
    [slsit_state_id_7]            CHAR (2)    NULL,
    [slsit_state_id_8]            CHAR (2)    NULL,
    [slsit_state_id_9]            CHAR (2)    NULL,
    [slsit_state_id_10]           CHAR (2)    NULL,
    [slsit_user_id]               CHAR (16)   NULL,
    [slsit_user_rev_dt]           INT         NULL,
    [A4GLIdentity]                NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_slsitmst] PRIMARY KEY NONCLUSTERED ([slsit_site_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Islsitmst0]
    ON [dbo].[slsitmst]([slsit_site_id] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[slsitmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[slsitmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[slsitmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[slsitmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[slsitmst] TO PUBLIC
    AS [dbo];

