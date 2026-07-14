       CTL-OPT nomain alwnull(*usrctl) option(*srcstmt)
       Copyright('AZ7 - Copyright CLAI Paytments Technologies.(C) Since 1993.');
       //-----------------------------------------------------------------*
       // AZ7 - Copyright CLAI Paytments Technologies.(C) Since 2026.
       //-----------------------------------------------------------------*
       // PT - Mass Mailing Test Suite Management
       //-----------------------------------------------------------------*
       // Seq.  Engineer                             Date        Draft
       // CL00  Albeiro Javier Lozano                2026-01-13  Qxxxx
       //-----------------------------------------------------------------*
        //dcl-f azbet keyed usage(*output:*input) rename(razbet:razbetn1);
        //dcl-f accmt keyed usage(*output:*input) rename(raccmt:raccmtn1);
       //-----------------------------------------------------------------*
       // Copies
       //-----------------------------------------------------------------*
       /COPY *LIBL/QTXTSRC,AYB177
       /COPY *LIBL/QTXTSRC,AY4565
       //-----------------------------------------------------------------*
       // files
       //-----------------------------------------------------------------*
       dcl-f azbdt keyed usage(*output:*delete);
       dcl-f attag keyed usage(*output:*input);
       dcl-f azbet keyed usage(*output:*delete);
       dcl-f azprm keyed usage(*input:*output);
       dcl-f azbre keyed usage(*input:*output);
       dcl-f azbex keyed usage(*output:*delete);
       dcl-f azipr keyed usage(*input);
       dcl-f azbsc keyed usage(*input);
       dcl-f azbhe keyed usage(*output:*delete);
       dcl-f azbftl1 keyed usage(*input) rename(razbft:razbftl1);
       dcl-f azmsg keyed usage(*output);
       dcl-f azbrr keyed usage(*output:*delete);
       dcl-f attagl1 keyed usage(*input) rename(rattag:RATTAB);
       dcl-f azmsgl1 keyed usage(*output:*delete) rename(razmsg:rmsg);
       //-----------------------------------------------------------------*
       // work-fields definitions
       //-----------------------------------------------------------------*
       dcl-c c_module const('AUTHORIZER');
       dcl-c c_function const('FUNCTION');
       //values submitted
       dcl-s ascr char(10) dim(350);
       dcl-s atra char(10) dim(350);
       dcl-s atag char(10) dim(50);
       dcl-s apgm char(10) dim(50);
       dcl-s vinp char(2560);
       dcl-s vtrama varchar(2560) inz(*blanks);
       dcl-s vdesbo char(10) inz(*blanks);
       dcl-s vclv char(128) inz(*blanks);
       dcl-s vout char(2560);
       dcl-s vlista char(20);
       dcl-s vtag char(4);
       dcl-s vval char(1024);
       dcl-s vCant zoned(7);
       //-----------------------------------------------------------------*
       // ds definitions
       //-----------------------------------------------------------------*
       dcl-ds azbpt dtaara('AZBPT') len(100);
         vlib char(10) pos(1);
       end-ds;
       dcl-ds azcfg LEN(100) dtaara('AZCFG');
         vsite char(1) POS(19);
       end-ds;
       //-----------------------------------------------------------------*
       // External programa definitions
       //-----------------------------------------------------------------*
       dcl-pr AT0005 extpgm('AT0005');
         *n char(3);
         *n char(2560);
         *n char(4);
         *n char(256);
       end-pr;
       dcl-pr AT0006 extpgm('AT0006');
         *n  char(3);
         *n  char(2560);
         *n  char(4);
         *n  packed(4:0);
         *n  char(256);
       end-pr;
       //=================================================================*
       // PUBLIC PROCEDURE
       //=================================================================*
       //-----------------------------------------------------------------*
       // Read accounts
       //-----------------------------------------------------------------*
       dcl-proc $amb177_read_accounts export;
         dcl-ds data_accmt ext inz(*extdft) extname('ACCMT') qualified end-ds;
         dcl-ds data_acccr ext inz(*extdft) extname('ACCCR') qualified end-ds;
         dcl-s v_currency zoned(3);
         dcl-s v_idname varchar(30);
         dcl-pi *n;
           typeid char(1) const;
           nameid char(30) const;
           statement_pan char(1) const;//estado pan
           statement_acc char(1) const;//estado de cuenta
           date_exp_ini zoned(8) const;//fecha inicio expiracion - desde
           date_exp_end zoned(8) const;//fecha inicio expiracion - hasta
           currency char(3) const;
           p_proc pointer(*proc) const;
         end-pi;

         dcl-pr cb_proc extproc(p_proc);
           *n pointer const;//accmt
           *n pointer const;//acccr
         end-pr;

         clear v_idname;
         v_currency = %int(currency);
         v_idname = %trim(nameid);

         EXEC SQL DECLARE LIST_USRS CURSOR FOR
           SELECT * FROM ACCMT AS A INNER JOIN ACCCR AS B
           ON A.CMTNUM  = B.CCRNUM
             WHERE (:statement_pan = 'T' OR A.CMTEST = :statement_pan)
             AND (:statement_acc = 'T' OR B.CCRSTS = :statement_acc)
             AND (A.CMTFEX >= :date_exp_ini AND A.CMTFEX <= :date_exp_end)
             AND (:v_currency = 999 OR B.CCRMON = :v_currency)
             AND ((:v_idname = '' )
             OR  (:typeid = '1' AND A.CMTCED = :v_idname)
             OR  (:typeid = '2' AND A.CMTNOM = :v_idname));
         EXEC SQL OPEN LIST_USRS;
         EXEC SQL FETCH LIST_USRS INTO :data_accmt, :data_acccr;
         dow sqlcod = 0;
           cb_proc(%addr(data_accmt):%addr(data_acccr));
           EXEC SQL FETCH LIST_USRS INTO :data_accmt, :data_acccr;
         enddo;
         EXEC SQL CLOSE LIST_USRS;
       end-proc;
       //-----------------------------------------------------------------*
       // get account
       //-----------------------------------------------------------------*
       dcl-proc $amb177_get_account export;
         dcl-ds data_accmt ext inz(*extdft) extname('ACCMT') qualified end-ds;
         dcl-ds data_acccr ext inz(*extdft) extname('ACCCR') qualified end-ds;
         dcl-ds res likeds(ds_amb177_data_account);
         dcl-pi *n likeds(res);
           v_account_num char(21) const;
           v_account_sec char(2) const;
         end-pi;
         clear res;
         EXEC SQL SELECT * INTO :data_accmt, :data_acccr
           FROM ACCMT AS A INNER JOIN ACCCR AS B
           ON A.CMTNUM  = B.CCRNUM
           WHERE CMTNUM = :v_account_num AND CMTSEC = :v_account_sec;
          res.found = *off;
          if sqlcod = 0;
            res.accmt = data_accmt;
            res.acccr = data_acccr;
            res.found = *on;
          endif;
          return res;
       end-proc;
       //-----------------------------------------------------------------*
       // read details cases
       //-----------------------------------------------------------------*
       dcl-proc $amb177_read_details_cases export;
         dcl-ds data_azbet ext inz(*extdft) extname('AZBET') qualified end-ds;
         dcl-pi *n;
           v_apl char(3) const;//BETSCR
           v_suite_id char(5) const;//BETTSI
           v_list_cases char(32000) const;//BETTRA
           pointer_proc pointer(*proc) const;
         end-pi;

         dcl-pr cb_proc extproc(pointer_proc);
           *n pointer const;//azbet
         end-pr;

         EXEC SQL
          DECLARE LIST_DETAILS_CASES CURSOR FOR
          SELECT * FROM AZBET
          WHERE BETSCR = :v_apl AND BETTSI = :v_suite_id
          AND (:v_list_cases = '|*ALL|'
           OR LOCATE('|' || RTRIM(BETTRA) || '|', :v_list_cases) > 0);
         EXEC SQL OPEN LIST_DETAILS_CASES;
         EXEC SQL FETCH LIST_DETAILS_CASES INTO :data_azbet;
         dow sqlcod = 0;
           cb_proc(%addr(data_azbet));
           EXEC SQL FETCH LIST_DETAILS_CASES INTO :data_azbet;
         enddo;
       end-proc;

       //******************************************************************
       //-----------------------------------------------------------------*
       // define details case
       //-----------------------------------------------------------------*
       dcl-proc $amb177_define_details_case export;
         dcl-ds data_azbdt ext inz(*extdft) extname('AZBDT') qualified end-ds;
         dcl-ds data_accmt ext inz(*extdft) extname('ACCMT') qualified end-ds;
         dcl-ds data_attag ext inz(*extdft) extname('ATTAG') qualified end-ds;
         dcl-s i zoned(10) inz(3);
         dcl-s aux_flags zoned(3) inz(0);
         dcl-ds flags_defined qualified;
           list_flags char(9) inz('015026027');
           //015: card number
           //026: date expiration: fecha de expiracion
           //027: user id number: cedula
           list_return char(3) dim(3) pos(1);
         end-ds;
         dcl-pi *n zoned(2);
           v_apl char(3) const;
           v_suite_id char(5) const;
           v_case_id char(10) const;
           v_card char(21) const;
           v_secuence char(2) const;
         end-pi;
         EXEC SQL
          SELECT * INTO :data_accmt FROM ACCMT
           WHERE CMTNUM = :v_card AND CMTSEC = :v_secuence;
         if sqlcod <> 0;
           return 1; //not data account
         endif;
         for i = 1 to 3;
           reset aux_flags;
           aux_flags = %int(flags_defined.list_return(i));
           EXEC SQL
           SELECT * INTO :data_attag, :data_azbdt
           FROM ATTAG AS A INNER JOIN AZBDT AS B
           ON A.TAGFQC = B.BDTSCR AND A.TAGCTG = B.BDTCTG
           WHERE A.TAGFQC = :v_apl AND B.BDTTSI = :v_suite_id
           AND B.BDTTRA = :v_case_id
           AND SUBSTR(A.TAGFLG, CAST(:aux_flags AS INTEGER), 1) = 'S';
           if sqlcod = 0;
             if data_azbdt.BDTEXC = 'S';
               chain (v_apl:v_suite_id:v_case_id:data_attag.TAGCTG) azbdt;
               if aux_flags = 15;//card number
                 BDTVAL = data_accmt.CMTNUM;
               elseif aux_flags = 26;//date expiration
                 BDTVAL = %char(data_accmt.CMTFEX);
               elseif aux_flags = 27;//user id number
                 BDTVAL = data_accmt.CMTCED;
               endif;
               update(e) razbdt;
               if %error;
                 unlock azbdt;
               endif;
             endif;
           endif;
         endfor;
         return 0;
       end-proc;
       //-----------------------------------------------------------------*
       // real-time delivery progress suites
       //-----------------------------------------------------------------*
       dcl-proc $amb177_realtime_delivery_progress_suites export;
         dcl-ds data_azbex ext inz(*extdft) extname('AZBEX') qualified end-ds;
         dcl-s num_recs zoned(10) inz(0);
         dcl-s count_cases_in_suite zoned(10) inz(0);
         dcl-pi *n;
           v_apls varchar(32000) const;
           v_suites varchar(32000) const;
           p_proc pointer(*proc) const;
         end-pi;

         dcl-pr cb_proc extproc(p_proc);
           *n pointer const;
           *n zoned(10) const;
         end-pr;
         reset num_recs;
         EXEC SQL DECLARE RT_DELIVERY_PROGRESS CURSOR FOR
         WITH records_list AS ( SELECT  A.*,
         ROW_NUMBER() OVER(
            PARTITION BY A.BEXAPL, A.BEXTSI
            ORDER BY A.BEXFEI DESC
         ) AS pos FROM AZBEX AS A
         WHERE :v_apls LIKE '%|' || TRIM(A.BEXAPL) || '|%'
         AND :v_suites LIKE '%|' || TRIM(A.BEXTSI) || '|%')
         SELECT * FROM records_list WHERE pos = 1;
         EXEC SQL OPEN RT_DELIVERY_PROGRESS;
         EXEC SQL FETCH RT_DELIVERY_PROGRESS INTO :data_azbex, :num_recs;
         dow sqlcod = 0;
            reset count_cases_in_suite;
            count_cases_in_suite = priv_count_cases_in_a_suite(
                                   data_azbex.BEXAPL:data_azbex.BEXTSI);
            cb_proc(%addr(data_azbex):count_cases_in_suite);
            EXEC SQL FETCH RT_DELIVERY_PROGRESS INTO :data_azbex , :num_recs;
         enddo;
         EXEC SQL CLOSE RT_DELIVERY_PROGRESS;
       end-proc;
       //-----------------------------------------------------------------*
       // submitted
       //-----------------------------------------------------------------*
       dcl-proc $amb177_submitted export;
         dcl-ds data_accmt ext inz(*extdft) extname('ACCMT') qualified end-ds;
         dcl-ds data_acccr ext inz(*extdft) extname('ACCCR') qualified end-ds;

         dcl-ds ds_cases extname('AZBET') qualified dim(2) inz end-ds;
         dcl-s rows_fetch int(10) inz(2);

         dcl-s v_currency zoned(3);
         dcl-s v_idname varchar(30);
         dcl-s total_cases zoned(10) inz(0);
         dcl-s i zoned(10) inz(0);
         dcl-s aux_suite char(5);
         dcl-s aux_apl char(3);

         dcl-pi *n zoned(3);
           typeid char(1) const;
           nameid char(30) const;
           statement_pan char(1) const;
           statement_acc char(1) const;
           date_exp_ini zoned(8) const;
           date_exp_end zoned(8) const;
           currency char(3) const;

           v_apl char(3) const;
           v_suite_id char(5) const;
           cases_list varchar(32000) const;
           p_proc pointer(*proc) const;
         end-pi;

         dcl-pr cb_proc extproc(p_proc);
           *n pointer const;//accmt
           *n pointer const;//acccr
         end-pr;

         v_currency = %int(currency);
         v_idname = %trim(nameid);

         EXEC SQL DECLARE C_CASES CURSOR FOR
           SELECT * FROM AZBET
           WHERE BETSCR = :v_apl AND BETTSI = :v_suite_id
           AND (:cases_list = '|*ALL|'
           OR LOCATE('|' || RTRIM(BETTRA) || '|', :cases_list) > 0);
         EXEC SQL OPEN C_CASES;
         EXEC SQL FETCH C_CASES FOR :rows_fetch ROWS INTO :ds_cases;
         total_cases = sqlerrd(3);

         EXEC SQL DECLARE LIST_ACCOUNTS CURSOR FOR
           SELECT * FROM ACCMT AS A INNER JOIN ACCCR AS B
           ON A.CMTNUM  = B.CCRNUM
             WHERE (:statement_pan = 'T' OR A.CMTEST = :statement_pan)
             AND (:statement_acc = 'T' OR B.CCRSTS = :statement_acc)
             AND (A.CMTFEX >= :date_exp_ini AND A.CMTFEX <= :date_exp_end)
             AND (:v_currency = 999 OR B.CCRMON = :v_currency)
             AND ((:v_idname = '' )
             OR  (:typeid = '1' AND A.CMTCED = :v_idname)
             OR  (:typeid = '2' AND A.CMTNOM = :v_idname));

         EXEC SQL OPEN LIST_ACCOUNTS;
         if total_cases = 0;
           return 1;
         endif;
         EXEC SQL FETCH LIST_ACCOUNTS INTO :data_accmt, :data_acccr;
         if sqlcod <> 0;
           return 2;
         endif;
         aux_apl = v_apl;
         aux_suite = v_suite_id;
         priv_generate_repository(aux_apl:aux_suite);
         dow 1=1;
           for i = 1 to total_cases;
             //ds_cases(i);
           endfor;
         enddo;
         EXEC SQL CLOSE LIST_ACCOUNTS;
         EXEC SQL CLOSE C_CASES;
       end-proc;
       //=================================================================*
       // Private Procedures
       //=================================================================*
       dcl-proc priv_generate_repository;
         //recupera sistema
         dcl-s vjobd char(10);
         dcl-s vljobd char(10);
         dcl-s vsbs char(10);
         //Inicializa Variables
         dcl-s descrip char(30);
         dcl-s formato char(10);
         //Valida ambiente
         dcl-s stasbs char(1);
         dcl-s vsts_sbs char(9);
         dcl-s tcdata zoned(10) inz(0);
         //Prepara repositorio
         dcl-s idrepo char(10);
         dcl-s vrepo char(10);
         dcl-s vfun packed(2) inz(1);
         dcl-s verr char(2);
         dcl-s vuser char(10) inz(*blanks);
         dcl-s vtime timestamp;
         dcl-s vdesc char(40);
         dcl-s vind char(1) inz('1');
         dcl-s vparm char(128);
         dcl-s res zoned(2) inz(0);
         //parameters
         dcl-pi *n;
           v_apl char(3);
           v_suite_id char(5);
         end-pi;

         dcl-pr AZB010P extpgm('AZB010P');
           *N char(10);
           *N char(1);
         end-pr;
         dcl-pr AZB008P ExtPgm('AZB008P');
           *N packed(2);
           *N char(10);
           *N char(3);
           *N char(128);
           *N char(10);
           *N char(2);
         end-pr;
         dcl-pr AZB042P ExtPgm('AZB042P');
           *n char(1);
           *n char(10);
           *n char(40);
         end-pr;

         //-------------------------------------------------*
         //recupera sistema
         //-------------------------------------------------*
         clear vjobd;
         clear vljobd;
         clear vsbs;
         in azcfg;//vsite ''
         EXEC SQL SELECT PRMSBS, PRMJOD, PRMLJD
         INTO :vsbs, :vjobd, :vljobd FROM AZPRM//AZSBSEMI - AZSEMID - SBSCLAI
         WHERE PRMIDS = :vsite and PRMCOD = :v_apl;
         //-------------------------------------------------*
         // Recupera descripcion y formato de envio
         //-------------------------------------------------*
         in azbpt;
         //vlib -> PTDEV
         res = 0; //variable de error
         EXEC SQL SELECT BSCDES, BSCUSE INTO :descrip, :formato FROM AZBSC
         WHERE BSCIDT = :v_suite_id;//MASTERCARD REPOSITORY - ISO8583
         //=========================================================*
         // Genera repositorio
         //=========================================================*
         //-------------------------------------------------*
         // Valida ambiente
         //-------------------------------------------------*
         clear vsts_sbs;
         clear stasbs;
         AZB010P(vsbs:stasbs);//AZSBSEMI - ('' -> A)
         select;
           when stasbs = 'A';
             vsts_sbs = 'ACTIVO   ';
           when stasbs = 'I';
             vsts_sbs = 'INACTIVO ';
           when stasbs = 'E';
               vsts_sbs = 'ERROR    ';
           when stasbs = 'X';
             vsts_sbs = 'NO EXISTE';
         endsl;
         //vsts_sbs -> ACTIVO
         EXEC SQL SELECT COUNT(*) INTO :TCDATA FROM AZBDT
         WHERE BDTTSI = :v_suite_id AND BDTVAL <> ' ';//tcdata -> 0000000376
         //-------------------------------------------------*
         // Valida ambiente Activo y datos en el caso
         //-------------------------------------------------*
         if vsts_sbs = 'ACTIVO' and tcdata > 0;
           //-------------------------------------------------*
           // Prepara repositorio
           //-------------------------------------------------*
           EXEC SQL SELECT NEXT VALUE FOR REPO_SEC
           INTO :idrepo
           FROM sysibm.sysdummy1;
           vrepo = %editc(%int(idrepo):'X'); //idrepo -> 195036
           %subst(vrepo:1:1) = 'R'; //vrepo = 'R000195036'

           clear vparm;
           AZB008P(vfun:vrepo:v_apl:vparm:vLib:vErr);
           //01 - R000195036 - MCI - '' - PTDEV - 00
           if verr = '00';
             vuser = wu_psds.PSDSUSRPRF;
             vtime = %timestamp();
             vdesc = v_apl + ' ' + v_suite_id + ' ' + %char(vtime);
             AZB042P(vind:vrepo:vdesc);//Recupera textos de archivos
             //(1:repo:vdesc)
             vuser = wu_psds.PSDSUSRPRF;
             EXEC SQL INSERT INTO AZBHE
             (BHEARC, BHECOD, BHEAPL, BHEFIN, BHEEST, BHEUSR)
             VALUES
             (:vrepo, :v_suite_id, :v_apl, :vtime, 'RUN', :vuser);
            endif;
         endif;
       end-proc;
       //-----------------------------------------------------------------*
       // define repository
       //-----------------------------------------------------------------*
       dcl-proc priv_define_repository;
         dcl-s vpar char(128) inz(*blanks);
         dcl-s vcant zoned(7) inz(0);
         dcl-s vini zoned(4) inz(0);
         dcl-s vLisTag1 char(20) inz('');
         dcl-s vLisTag2 char(20) inz('');
         dcl-s vtp char(15);
         dcl-s vtagpgm char(128) inz(*blanks);
         dcl-s v_sequence char(200) inz(*blanks);
         dcl-s vlen packed(15) inz(*zeros);
         dcl-s vtrama varchar(2560) inz(*blanks);
         dcl-s vmti char(4);
         dcl-s vmantorig char(1);
         dcl-s vtipoflg char(1);
         dcl-s vtime timestamp;
         dcl-s vmac char(18);
         dcl-s vatm char(3);
         dcl-s vcanreg zoned(10) inz(0);
         dcl-s vlng zoned(4);
         dcl-pi *n;
           v_apl char(3);
           v_suite_id char(5);
           v_repository char(10);
         end-pi;

         dcl-pr CMD extpgm('QCMDEXC');
           *n char(200) const;
           *n packed(15:5) const;
         end-pr;
         dcl-pr pgmconvermsg extpgm(BFTAPI);
           *n char(3);
           *n char(128);
           *n char(2560);
           *n char(2560);
         end-pr;
         dcl-pr AZB115 extpgm('AZB115');
           *n char(3);
           *n char(3);
           *n char(2560);
           *n char(18);
         end-pr;
         //-------------------------------------------------*
         // Rutina de inicio
         //-------------------------------------------------*
         in azbpt;
         chain (' ':v_apl) azprm;
         chain(n) (v_suite_id:v_apl) azbsc;
         chain(n) (bscuse) azbftl1;
         vcant = 0;
         clear aScr;
         clear aTra;
         clear aTag;
         clear aPgm;
         clear vpar;
         msgapl = v_apl;
         msgjob = 'AZTRAPD001';
         msgdir = 'REC';
         msgnxt = ' ';
         brrapl = v_apl;
         brrtsi = v_suite_id;
         evalr brridr = v_repository;
         brrnam = v_repository;
         brrusr = wu_psds.PSDSUSRPRF;
         brrver = %char(%timestamp());
         brrtc2 = *blanks;
         vini = 1;
         //Rescata Tag's Claves
         vLisTag1 = *blanks;
         vLisTag2 = *blanks;
         setll (v_apl) rattab;
         reade(n) v_apl rattab;
         dow not %eof(attagl1);
           if %subst(tagflg:1:1) = 'S';
             vLisTag1 = %trim(vLisTag1) + %trim(tagctg);
           endif;
           if %subst(tagflg:2:1) = 'S';
             vLisTag2 = %trim(vLisTag2) + %trim(tagctg);
           endif;
           if tagpgc <> '*NONE';
             clear vtp;
             vtp = tagctg + tagpgc;
             %subst(vtagpgm:vini:15) = vtp;
             vini = vini + 14;
           endif;
           reade(n) v_apl rattab;
         enddo;
         //-----------------------------------------------------
         // genera repositorio con un solo ciclo
         //-----------------------------------------------------
         v_sequence='OVRDBF FILE(AZMSG) +
              TOFILE(' + %trim(vLib) + '/R000000000) +
              MBR(' + %trim(v_repository) + ')' ;
         vlen = %len(v_sequence);
         CMD(v_sequence:vlen);

         setll (bscscr:bscidt:bettra) azbet;
         reade(n) (bscscr:bscidt) azbet;
         dow not %eof(azbet);
           clear bdtctg;
           clear vtrama;
           clear vdesbo;
           clear vclv;
           vmti = %subst(betpar:1:4);
           vmantorig = %subst(betpar:50:1);

           setll (betscr:bettsi:bettra:bdtctg) azbdt;
           reade(n) (betscr:bettsi:bettra) azbdt;
           dow not %eof(azbdt) and vdesbo = *blanks;
             //armando trama
             reade(n) (betscr:bettsi:bettra) azbdt;
           enddo;

           if vtrama <> *blanks and vdesbo = *blanks;
             vinp = vtrama;
             if vLisTag1 <> *blanks;
               clear vlista;
               vlista = vLisTag1;
               vtipoflg = '1';
               //exsr rescatatags;
             endif;
             if vLisTag2 <> *blanks;
               clear vlista;
               vlista = vLisTag2;
               vtipoflg = '2';
               //exsr rescatatags;
              endif;
              msgsrc = bettra;
              msgfec = %dec(%date():*iso);
              vtime=%timestamp();
              msghor=%dec(%time(vtime));
              msgmil=%dec(%subdt(vtime:*mseconds))/1000;
              chain (brridr:v_suite_id:bettra) azbrr;
              if not %found(azbrr);
                brrtci = bettra;
                brrdes = betdes;
                if prmcvr = 'I';
                  brrfil = brrtci + %subst(betpar:1:4) + vclv;
                  %subst(brrflg:43:1) = 'S';
                else;
                  brrfil = brrtci + vclv;
                endif;
                %subst(brrflg:1:2) = betcde;
                %subst(brrflg:4:2) = betres;
                %subst(brrflg:7:4) = %subst(betpar:1:4);
                %subst(brrflg:23:19) = %subst(betpar:10:19);
                brrmsg = vinp;
                write razbrr;
              endif;
              betfil = brrtci + vclv;
              update razbet;
              clear msgnxt;
              clear msgdta;
              clear msgcun;
              vpar = betpar;
              %subst(vpar:118:10) = bettra;
              clear vout;
              if bftapi <> *blanks;
                pgmconvermsg(v_apl:vpar:vinp:vout);
              else;
              vout = vinp;
              endif;
              msgcun = betfil;
              select;
                when %len(%trim(vout))<= 2560;
                  msgdta = %subst(vout:1:2560);
                  if v_apl = 'ATM';
                    vinp = vtrama;
                    vtag = 'D003';
                    AT0005(v_apl:vinp:vtag:vval);
                    vinp = msgdta;
                    vatm = vval;
                    vlng = %checkr(' ':vinp);
                    vinp = %subst(vinp:1:vlng-1);
                    azb115(v_apl:vatm:vinp:vmac);
                    if vmac <> *blanks;
                      vlng = %checkr(' ':msgdta);
                      %subst(msgdta:vlng+1) = vmac;
                    endif;
                  endif;
                other;
                  msgnxt = '1';
                  msgdta = %subst(vout:1:2560);
                  write razmsg;
                  msgnxt = '2';
                  msgdta = %subst(vout:1:2560);
                  write razmsg;
              endsl;
              //Actualiza AZBHE
              chain v_repository azbhe;
              if %found(azbhe);
                vcanreg +=1;
                bhecan = %char(vcanreg);
                bheusr = wu_psds.PSDSUSRPRF;
                update razbhe;
              endif;
           endif;
           reade (bscscr:bscidt) azbet;
         enddo;
       end-proc;
       //-----------------------------------------------------------------*
       // genera trama
       //-----------------------------------------------------------------*
       dcl-proc priv_genera_trama;
         dcl-ds regtag likerec(rattag);
         dcl-s wtrama char(2560) inz(*blanks);
         dcl-s vx packed(3);
         dcl-s vlontrama packed(4) inz(0);
         dcl-s vdata char(24) inz(*blanks);
         dcl-c lgtramax const(2560);
         dcl-ds *n;
           wlongn  zoned(4:0);
           wlongc  char(4) overlay(wlongn);
         end-ds;
         dcl-pi *n;
           v_apl char(3);
           v_suite_id char(5);
         end-pi;

         dcl-pr pgmconvertag extpgm(regtag.tagpgc);
           *n char(3);
           *n char(5);
           *n char(4);
           *n char(10);
           *n char(2560);
           *n char(2560);
         end-pr;

         if bdtexc <> 'N';
           regtag = fntagreg(bscdic:bdtctg);
           wlongn = regtag.taglon;
           if wlongn > 0 and ((%len(vTrama)+wlongn)<LgTramax);
             if regtag.tagfor = 'E';
               //exsr subtags
               bdtval = wtrama;
             endif;
             if  regtag.tagpgc <> '*NONE'
             and regtag.tagpgc <> '*none'
             and regtag.tagpgc <> *blanks
             and regtag.tagpgc <> *zeros;
               vinp = vtrama;
               pgmconvertag(v_apl:v_suite_id:bdtctg:bdttra:vinp:bdtval);
               if vx < %elem(atra);
                 ascr(vx) = %trim(bdtscr);
                 atra(vx) = %trim(bdttra);
                 if %lookup(bdtctg:atag) = 0;
                   atag(vx) = %trim(bdtctg);
                   apgm(vx) = %trim(regtag.tagpgc);
                 endif;
                 vx += 1;
               endif;
             endif;
             chain(n) (v_apl:bdtctg) attag;
             if %found(attag);
               if tagtlg = 'V';
                 wlongn = %len(%trim(bdtval));
                 if wlongn = 0;
                   wlongn = regtag.taglon;
                 endif;
               endif;
             endif;
             chain v_apl azipr;
             if %found(azipr);
               if iprhdr = 'V';
                 vlontrama = wlongn/2;
                 evalr vdata = %char(vlontrama);
               endif;
             endif;
           else;
             vdesbo = bettra;
           endif;
         endif;
       end-proc;
       //-----------------------------------------------------------------*
       // rescata tags
       //-----------------------------------------------------------------*
       dcl-proc rescata_tags;
         dcl-s vcont_46 packed(2);
         dcl-s tlng packed(4);
         dcl-s tlng_ini packed(4);
         dcl-s tlng_fin packed(4);
         dcl-s inil_n zoned(4);
         dcl-s vmsg char(70);
         dcl-s vvalbk char(1024);
         dcl-s vTipoFlg char(1);
         dcl-s vpos char(3);
         dcl-s vlon char(3);
         dcl-s xpos zoned(4);
         dcl-s vMantOrig char(1);
         dcl-ds vlngt len(4);
           vlngt_a  char(4)  pos(1);
           vlngt_n  zoned(4) pos(1);
         end-ds;
         dcl-ds xVal len(20);
           xVal_A  char(20)  pos(1);
           xVal_N  zoned(20) pos(1);
         end-ds;
         dcl-pi *n;
           v_apl char(3);
           v_suite_id char(5);
         end-pi;
         dcl-pr AZB046 extpgm('AZB046');
           *n  char(20);
         end-pr;

         clear vcont_46;
         tlng_ini = 1;
         clear tlng_fin;
         clear vmsg;

         vout = *blanks;
         vclv = *blanks;
         //Saca Tags Claves para Actualizar AZBDT
         vtag = %subst(vlista:1:4);
         inil_n = 1;
         vlngt_n = %len(%trim(vlista));
         dow inil_n < vlngt_n;
           //Rescata el Valor Del TTAG
           AT0005(v_apl:vinp:vtag:vval);
           vvalbk = vval;
           tlng = %len(%trim(vval));
           inil_n = inil_n + 4;
           //Rescata Nuevo Tag
           if vTipoFlg = '2';
           //Clear vMsg;
             tlng_fin = (tlng_ini + tlng) - 1;
             if tlng_fin > 20;
               clear vcont_46;
               tlng_ini = 1;
               clear tlng_fin;
               clear vmsg;
             endif;
             if vcont_46 = *zeros;
                AZB046 (vMsg);
               vcont_46 = 1;
             endif;
             vval = %subst(vmsg:tlng_ini:tlng);
             tlng_ini = tlng_ini + tlng;
             vClv = %Trim(vClv) + %Trim(vVal);
           endif;
           If vTipoFlg = '1';
             chain(n) (v_apl:vTag) attag;
             If %found(attag);
               If %subst(tagflg:3:3) <> *Blanks;
                 vPos = %subst(tagflg:3:3);
                 vLon = %subst(tagflg:6:3);
                 Evalr xVal = %subst(vVal:%int(vPos):%int(vLon));
                 xVal = %Xlate(' ':'0':xVal);
                 xVal_N = xVal_N + vCant;
                 xPos = 20 - %int(vLon);
                 %subst(vVal:%int(vPos):%int(vLon)) =
                 %subst(xVal:xPos+1:%int(vLon));
               Else;
                 if vMantOrig <> 'S';
                   xVal = vVal;
                   xVal_N = vCant + 1;
                   vVal = xVal;
                 endif;
               EndIf;
             EndIf;
           EndIf;
           //Inserta Nuevo Valor En Tag único
           AT0006(v_apl:vinp:vtag:tlng:vval);
           vtag = %SubsT(vlista:inil_n:4);
         enddo;
       end-proc;
       //**********************************************************************
       //**********************************************************************
       //**********************************************************************
       //**********************************************************************
       //**********************************************************************
       //**********************************************************************





















       //-----------------------------------------------------------------*
       // -----------------------
       //-----------------------------------------------------------------*
       dcl-proc fntagreg;
         dcl-pi *n likerec(Rattag);
           vtagFqc  char(3) value;
           vtagctg  char(4) value;
         end-pi;

         dcl-ds regtagds likerec(Rattag);

         // Operación de búsqueda nativa
         chain (vtagFqc:vtagctg) Rattag regtagDs;

         if not %found;
           clear regtagDs;
         endif;

         return regtagds;
       end-proc;
       //-----------------------------------------------------------------*
       // -----------------------
       //-----------------------------------------------------------------*
       dcl-proc fngetvaltag;
         dcl-c lgcammax const(9999);
         dcl-s wbdtval   varchar(9999);
         dcl-s ibdtval   char(9999);
         dcl-s wtaglonn  packed(4:0);
         dcl-s wfield    char(1024);
         dcl-s wlen      packed(4:0) inz(0);
         dcl-pi *n varchar(9999);
           xtaglonn  packed(4:0) value;
           xbdtval   char(9999)  value;
           xtagfor   char(1)     value;
         end-pi;

         dcl-pr AZ0717 extpgm('AZ0717');
           *n packed(4:0) const;
           *n char(1024) const;
         end-pr;

         wtaglonn = xtaglonn;
         if xtaglonn > lgcammax;
           wtaglonn = lgcammax;
         endif;

         select;
           when (xtagfor = 'N' or xtagfor = 'P');
             if xtagfor = 'P';
               wfield = %subst(xbdtval: 1: 1024);
               wlen = %len(%trim(wfield));

               if wlen < wtaglonn;
                 %subst(wfield: wtaglonn - wlen + 1: wlen) = %trim(wfield);
                 %subst(wfield: 1: wtaglonn - wlen) = *zeros;
               endif;

               az0717(wtaglonn: wfield);
               %subst(xbdtval: 1: 1024) = wfield;
             endif;

             evalr ibdtval = %trim(xbdtval);
             wbdtval = %xlate(' ': '0'
                       :%subst(ibdtval: lgcammax - wtaglonn + 1: wtaglonn));

           other;
             if %subst(BdtFlg: 12: 1) = 'S';
               ibdtval = xbdtval;
             else;
               ibdtval = %trim(xbdtval);
             endif;

             wbdtval = %subst(ibdtval: 1: wtaglonn);
         endsl;

         return wbdtval;
       end-proc;
       //-----------------------------------------------------------------*
       // count cases in a suite
       //-----------------------------------------------------------------*
       dcl-proc priv_count_cases_in_a_suite;
         dcl-s count_cases zoned(10) inz(0);
         dcl-pi *n like(count_cases);
           v_apl char(3) const;
           v_suite_id char(5) const;
         end-pi;
         reset count_cases;
         EXEC SQL SELECT COUNT(*) INTO :count_cases FROM AZBET
         WHERE BETSCR = :v_apl AND BETTSI = :v_suite_id;
         return count_cases;
       end-proc;
