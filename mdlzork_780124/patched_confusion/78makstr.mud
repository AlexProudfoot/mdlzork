<SETG GLOHI 1>

<SETG STAR-BITS 0>

<DEFINE CEVENT (TICK APP FLG NAME "AUX" (OBL <GET INITIAL OBLIST>) ATM)
        #DECL ((TICK) FIX (APP) <OR APPLICABLE NOFFSET> (FLG) <OR ATOM FALSE>
               (NAME) <OR ATOM STRING> (ATM) <OR ATOM FALSE>)
        <COND (<TYPE? .NAME STRING>
               <COND (<SET ATM <LOOKUP .NAME .OBL>>)
                     (T <SET ATM <INSERT .NAME .OBL>>)>)
              (<SET ATM .NAME>)>
        <SETG .ATM <CHTYPE [.TICK .APP .FLG .ATM] CEVENT>>>

<DEFINE CEXIT (FLID RMID "OPTIONAL" (STR <>) (FLAG <>) (FUNCT <>) "AUX" (FVAL <>) ATM)
        #DECL ((STR) <OR FALSE STRING> (FLID RMID) <OR ATOM STRING>
               (ATM FUNCT) <OR ATOM FALSE> (FVAL) <OR APPLICABLE FALSE>
               (FLAG) <OR ATOM FALSE>)
        <COND (<TYPE? .FLID ATOM> <SET FLID <SPNAME .FLID>>)>
        <SET ATM <OR <LOOKUP .FLID <GET FLAG OBLIST>>
                     <INSERT .FLID <GET FLAG OBLIST>>>>
        <SETG .ATM .FLAG>
        <CHTYPE <VECTOR .ATM <FIND-ROOM .RMID> .STR .FUNCT> CEXIT>>

<DEFINE DOOR (OID RM1 RM2 "OPTIONAL" (STR <>) (FN <>) "AUX" (OBJ <FIND-OBJ .OID>))
        #DECL ((OID) STRING (STR) <OR STRING FALSE> (FN) <OR ATOM FALSE>
               (OBJ) OBJECT (RM1 RM2) <OR STRING ROOM>)
        <COND (<FIND-DOOR <SET RM1 <FIND-ROOM .RM1>> .OBJ>)
              (<FIND-DOOR <SET RM2 <FIND-ROOM .RM2>> .OBJ>)
              (<CHTYPE [.OBJ .RM1 .RM2 .STR .FN] DOOR>)>>

<DEFINE EXIT ("TUPLE" PAIRS "AUX" (DOBL ,DIRECTIONS)
              (FROB <IVECTOR <LENGTH .PAIRS>>))
        #DECL ((PAIRS) <TUPLE [REST STRING <OR DOOR NEXIT CEXIT STRING ATOM>]>
               (DIR) <LIST [REST ATOM]> (FROB) VECTOR (DOBL) OBLIST)
        <REPEAT (ATM RM (F .FROB))
          #DECL ((ATM) <OR ATOM FALSE> (RM) <OR ROOM FALSE> (F) VECTOR)
          <COND (<OR
                  <AND <SET ATM <LOOKUP <1 .PAIRS> .DOBL>>
                       <GASSIGNED? .ATM>
                       <TYPE? ,.ATM DIRECTION>>>
                 <PUT .F 1 .ATM>
                 <COND (<TYPE? <2 .PAIRS> STRING>
                        <PUT .F 2 <FIND-ROOM <2 .PAIRS>>>)
                       (<PUT .F 2 <2 .PAIRS>>)>
                 <SET F <REST .F 2>>)
                (T
                 <PUT .PAIRS 1 <ERROR ILLEGAL-DIRECTION <1 .PAIRS>>>)>
          <COND (<EMPTY? <SET PAIRS <REST .PAIRS 2>>>
                 <RETURN>)>>
        <CHTYPE .FROB EXIT>>

<DEFINE ROOM (ID D1 D2 LIT? EX "OPTIONAL" (OBJS ()) (APP <>) (VAL 0) (BIT ,RLANDBIT)
              (GLOB 0) "AUX" (RM <FIND-ROOM .ID>))
        #DECL ((ID) <OR STRING ATOM> (D1 D2) STRING (LIT?) <OR ATOM FORM FALSE>
               (EX) EXIT (APP) <OR FORM FALSE ATOM> (VAL BIT GLOB) FIX (RM) ROOM)
        <SETG SCORE-MAX <+ ,SCORE-MAX .VAL>>
        <PUT .RM ,RGLOBAL <+ .GLOB ,STAR-BITS>>
        <PUT .RM ,RVAL .VAL>
        <PUT .RM ,ROBJS .OBJS>
        <PUT .RM ,RDESC1 .D1>
        <PUT .RM ,RDESC2 .D2>
        <PUT .RM ,REXITS .EX>
        <PUT .RM ,RACTION <COND (<TYPE? .APP FALSE FORM> <>) (.APP)>>
        <COND (<TYPE? .LIT? FALSE FORM>) (ELSE <SET BIT <+ .BIT ,RLIGHTBIT>>)>
        <MAPF <>
              <FUNCTION (X) #DECL ((X) OBJECT)
                        <PUT .X ,OROOM .RM>>
              <ROBJS .RM>>
        <PUT .RM ,RBITS .BIT>
        .RM>

<DEFINE SOBJECT (ID STR "TUPLE" TUP) 
        #DECL ((ID) STRING (TUP) TUPLE)
        <OBJECT .ID "" .STR %<> <> () <> <+ !.TUP>>>

<DEFINE AOBJECT (ID STR APP "TUPLE" TUP) 
        #DECL ((ID) STRING (TUP) TUPLE (APP) ATOM)
        <OBJECT .ID "" .STR %<> .APP () <> <+ !.TUP>>>

<DEFINE GOBJECT (IDS STR APP NAM "TUPLE" TUP "AUX" (OBJOB ,OBJECT-OBL) OBJ)
        #DECL ((IDS) <VECTOR [REST STRING]> (STR) STRING (APP) <OR ATOM FALSE>
               (TUP) TUPLE (OBJ) OBJECT (OBJOB) OBLIST (NAM) <OR FALSE ATOM>)
        <SET OBJ <OBJECT <1 .IDS> "" .STR %<> .APP () <> <+ !.TUP>>>
        <PUT .OBJ ,OGLOBAL <SETG GLOHI <* ,GLOHI 2>>>
        <AND .NAM <SETG .NAM ,GLOHI>>
        <MAPF <>
              <FUNCTION (X)
                        #DECL ((X) STRING)
                        <SETG <OR <LOOKUP .X .OBJOB>
                                  <INSERT .X .OBJOB>> .OBJ>>
              <REST .IDS>>
        .OBJ>
                        
<DEFINE OBJECT (ID DESC1 DESC2 DESCO APP CONTS CAN FLAGS
                "OPTIONAL" (S1 0) (S2 0) (SIZE 5) (CAPAC 0)
                "AUX" (OBJ <FIND-OBJ .ID>))
        #DECL ((ID) <OR ATOM STRING> (DESC1 DESC2) STRING (APP) <OR FALSE FORM ATOM>
               (CONTS) <LIST [REST OBJECT]> (CAN) <OR FALSE OBJECT>
               (FLAGS) <PRIMTYPE WORD> (SIZE CAPAC) FIX (OBJ) OBJECT
               (S1 S2) FIX (DESCO) <OR STRING FALSE>)
        <SETG SCORE-MAX <+ ,SCORE-MAX .S1 .S2>>
        <PUT .OBJ ,ODESC1 .DESC1>
        <PUT .OBJ ,ODESC2 .DESC2>
        <PUT .OBJ ,ODESCO .DESCO>
        <PUT .OBJ ,OACTION <COND (<TYPE? .APP FALSE FORM> <>) (.APP)>>
        <PUT .OBJ ,OCONTENTS .CONTS>
        <PUT .OBJ ,OCAN .CAN>
        <PUT .OBJ ,OFLAGS .FLAGS>
        <PUT .OBJ ,OFVAL .S1>
        <PUT .OBJ ,OTVAL .S2>
        <PUT .OBJ ,OSIZE .SIZE>
        <PUT .OBJ ,OCAPAC .CAPAC>>

<DEFINE FIND-PREP (STR "AUX" (ATM <ADD-WORD .STR>))
    #DECL ((STR) STRING (ATM) <OR FALSE ATOM>)
    <COND (<GASSIGNED? .ATM>
           <COND (<TYPE? ,.ATM PREP> ,.ATM)
                 (<ERROR NO-PREP!-ERRORS>)>)
          (<SETG .ATM <CHTYPE .ATM PREP>>)>>

<DEFINE ADD-ACTION (NAM STR "TUPLE" DECL
                            "AUX" (ATM <OR <LOOKUP .NAM ,ACTIONS>
                                           <INSERT .NAM ,ACTIONS>>))
    #DECL ((NAM STR) STRING (DECL) <TUPLE [REST VECTOR]> (ATM) ATOM)
    <SETG .ATM <CHTYPE [.ATM <MAKE-ACTION !.DECL> .STR] ACTION>>
    .ATM>

<DEFINE ADD-DIRECTIONS ("TUPLE" NMS "AUX" (DIR ,DIRECTIONS) ATM)
    #DECL ((NMS) <TUPLE [REST STRING]> (DIR) OBLIST (ATM) ATOM)
    <MAPF <> <FUNCTION (X) <SETG <SET ATM <OR <LOOKUP .X .DIR> <INSERT .X .DIR>>>
                                 <CHTYPE .ATM DIRECTION>>>
          .NMS>>

<DEFINE DSYNONYM (STR "TUPLE" NMS "AUX" VAL (DIR ,DIRECTIONS) ATM)
    #DECL ((ATM) ATOM (STR) STRING (NMS) <TUPLE [REST STRING]>
           (VAL) DIRECTION (DIR) OBLIST)
    <SET VAL <ADD-DIRECTIONS .STR>>
    <MAPF <> <FUNCTION (X) <SETG <SET ATM <OR <LOOKUP .X .DIR> <INSERT .X .DIR>>>
                                 .VAL>>
          .NMS>>

<DEFINE VSYNONYM (N1 "TUPLE" N2 "AUX" ATM VAL) 
        #DECL ((N1) STRING (N2) <TUPLE [REST STRING]> (ATM) <OR FALSE ATOM>
               (VAL) ANY)
        <COND (<SET ATM <LOOKUP .N1 ,WORDS>>
               <SET VAL ,.ATM>
               <MAPF <> <FUNCTION (X) <SETG <ADD-WORD .X> .VAL>> .N2>)>
        <COND (<SET ATM <LOOKUP .N1 ,ACTIONS>>
               <SET VAL ,.ATM>
               <MAPF <> <FUNCTION (X) <SETG <OR <LOOKUP .X ,ACTIONS>
                                                <INSERT .X ,ACTIONS>>
                                            .VAL>> .N2>)>>

"STUFF FOR ADDING TO VOCABULARY, ADDING TO LISTS (OF DEMONS, FOR EXAMPLE)."

<DEFINE ADD-WORD (W) 
        #DECL ((W) STRING)
        <OR <LOOKUP .W ,WORDS> <INSERT .W ,WORDS>>>

<DEFINE ADD-BUZZ ("TUPLE" W) 
        #DECL ((W) <TUPLE [REST STRING]>)
        <MAPF <>
              <FUNCTION (X) 
                      #DECL ((X) STRING)
                      <SETG <ADD-WORD .X> <CHTYPE .X BUZZ>>>
              .W>>

<DEFINE ADD-ZORK (NM "TUPLE" W) 
        #DECL ((NM) ATOM (W) <TUPLE [REST STRING]>)
        <MAPF <>
              <FUNCTION (X "AUX" ATM) 
                      #DECL ((X) STRING (ATM) ATOM)
                      <SETG <SET ATM <ADD-WORD .X>> <CHTYPE .ATM .NM>>>
              .W>>

<DEFINE ADD-OBJECT (OBJ NAMES "OPTIONAL" (ADJ '[]) "AUX" (OBJS ,OBJECT-OBL)) 
        #DECL ((OBJ) OBJECT (NAMES ADJ) <VECTOR [REST STRING]> (OBJS) OBLIST)
        <PUT .OBJ
             ,ONAMES
             <MAPF ,UVECTOR
                   <FUNCTION (X) 
                           #DECL ((X) STRING)
                           <OR <LOOKUP .X .OBJS> <INSERT .X .OBJS>>>
                   .NAMES>>
        <PUT .OBJ ,OADJS <MAPF ,UVECTOR <FUNCTION (W) <ADD-ZORK ADJECTIVE .W>> .ADJ>>
        <CHUTYPE <OADJS .OBJ> ADJECTIVE>
        .OBJ>

<DEFINE SYNONYM (N1 "TUPLE" N2 "AUX" ATM VAL) 
        #DECL ((N1) STRING (N2) <TUPLE [REST STRING]> (ATM) <OR FALSE ATOM>
               (VAL) ANY)
        <COND (<SET ATM <LOOKUP .N1 ,WORDS>>
               <SET VAL ,.ATM>
               <MAPF <> <FUNCTION (X) <SETG <ADD-WORD .X> .VAL>> .N2>)>>

<DEFINE ADD-ABBREV (X Y "AUX") 
        #DECL ((X Y) STRING)
        <SETG <ADD-WORD .X> <OR <LOOKUP .Y ,WORDS> <INSERT .Y ,WORDS>>>>

<DEFINE ADD-DEMON (X) #DECL ((X) HACK)
  <COND (<MAPR <>
          <FUNCTION (Y) #DECL ((Y) <LIST [REST HACK]>)
            <COND (<==? <HACTION <1 .Y>> <HACTION .X>>
                   <PUT .Y 1 .X>
                   <MAPLEAVE T>)>>
          ,DEMONS>)
        (<SETG DEMONS (.X !,DEMONS)>)>>

<DEFINE ADD-STAR (OBJ) 
        <SETG STAR-BITS <+ ,STAR-BITS <OGLOBAL .OBJ>>>>

<DEFINE ADD-ACTOR (ADV "AUX" (ACTORS ,ACTORS))
  #DECL ((ADV) ADV (ACTORS) <LIST [REST ADV]>)
  <COND (<MAPF <>
               <FUNCTION (X) #DECL ((X) ADV)
                 <COND (<==? <AOBJ .X> <AOBJ .ADV>>
                        <MAPLEAVE T>)>>
               .ACTORS>)
        (<SETG ACTORS (.ADV !.ACTORS)>)>
  .ADV>

<DEFINE ADD-DESC (OBJ STR)
    #DECL ((OBJ) OBJECT (STR) STRING)
    <PUT .OBJ ,OREAD .STR>>

<DEFINE SADD-ACTION (STR1 ATM)
    <ADD-ACTION .STR1 "" [[.STR1 .ATM]]>>

<DEFINE 1ADD-ACTION (STR1 STR2 ATM)
    <ADD-ACTION .STR1 .STR2 [OBJ [.STR1 .ATM]]>>

"MAKE-ACTION:  Function for creating a verb.  Takes;

        vspec => [objspec {\"prep\"} {objspec} [atom!-WORDS fcn] extras]

        objspec => OBJ | objlist

        objlist => ( objbits {fwimbits} {NO-TAKE} {MUST-HAVE} {TRY-TAKE} {=} )

        extras => DRIVER FLIP

Creates a VSPEC.
"

<DEFINE MAKE-ACTION ("TUPLE" SPECS "AUX" VV SUM (PREP <>) ATM) 
   #DECL ((SPECS) TUPLE (VV) <PRIMTYPE VECTOR> (SUM) FIX (PREP ATM) ANY)
   <CHTYPE
    <MAPF ,UVECTOR
     <FUNCTION (SP "AUX" (SYN <VECTOR <> <> <> 0>) (WHR 1)) 
        #DECL ((SP) VECTOR (SYN) VECTOR (WHR) FIX)
        <MAPF <>
         <FUNCTION (ITM) 
                 #DECL ((ITM) ANY)
                 <COND (<TYPE? .ITM STRING> <SET PREP <FIND-PREP .ITM>>)
                       (<AND <==? .ITM OBJ> <SET ITM '(-1 ROBJS AOBJS)> <>>)
                       (<TYPE? .ITM LIST>
                        <SET VV <IVECTOR 4>>
                        <PUT .VV ,VBIT <1 .ITM>>
                        <COND (<AND <NOT <LENGTH? .ITM 1>> <TYPE? <2 .ITM> FIX>>
                               <PUT .VV ,VFWIM <2 .ITM>>)
                              (ELSE
                               <PUT .VV ,VBIT -1>
                               <PUT .VV ,VFWIM <1 .ITM>>)>
                        <AND <MEMQ = .ITM> <PUT .VV ,VBIT <VFWIM .VV>>>
                        <PUT .VV ,VPREP .PREP>
                        <SET SUM 0>
                        <SET PREP <>>
                        <AND <MEMQ AOBJS .ITM> <SET SUM <+ .SUM ,VABIT>>>
                        <AND <MEMQ ROBJS .ITM> <SET SUM <+ .SUM ,VRBIT>>>
                        <AND <MEMQ NO-TAKE .ITM> <SET SUM .SUM>>
                        <AND <MEMQ HAVE .ITM> <SET SUM <+ .SUM ,VCBIT>>>
                        <AND <MEMQ TRY .ITM> <SET SUM <+ .SUM ,VTBIT>>>
                        <AND <MEMQ TAKE .ITM> <SET SUM <+ .SUM ,VTBIT ,VCBIT>>>
                        <PUT .VV ,VWORD .SUM>
                        <PUT .SYN .WHR <CHTYPE .VV VARG>>
                        <SET WHR <+ .WHR 1>>)
                       (<TYPE? .ITM VECTOR>
                        <COND (<GASSIGNED? <SET ATM <ADD-WORD <1 .ITM>>>>
                               <PUT .SYN ,SFCN ,.ATM>)
                              (<PUT .SYN
                                    ,SFCN
                                    <SETG <SET ATM <ADD-WORD <1 .ITM>>>
                                          <CHTYPE [.ATM <2 .ITM>] VERB>>>)>)
                       (<==? .ITM DRIVER>
                        <PUT .SYN ,SFLAGS <CHTYPE <ORB <SFLAGS .SYN> ,SDRIVER> FIX>>)
                       (<==? .ITM FLIP>
                        <PUT .SYN ,SFLAGS <CHTYPE <ORB <SFLAGS .SYN> ,SFLIP> FIX>>)>>
         .SP>
        <OR <SYN1 .SYN> <PUT .SYN ,SYN1 ,EVARG>>
        <OR <SYN2 .SYN> <PUT .SYN ,SYN2 ,EVARG>>
        <CHTYPE .SYN SYNTAX>>
     .SPECS>
    VSPEC>>



"Default value for syntax slots not specified"

<SETG EVARG <CHTYPE [0 0 <> 0] VARG>>

<GDECL (EVARG) VARG>

; "To add VERBs to the BUNCHERS list"

<DEFINE ADD-BUNCHER ("TUPLE" STRS) 
        #DECL ((STRS) <TUPLE [REST STRING]>)
        <MAPF <>
              <FUNCTION (STR) 
                      #DECL ((STR) STRING)
                      <SETG BUNCHERS
                            (,<LOOKUP .STR <GET WORDS OBLIST>> !,BUNCHERS)>>
              .STRS>>

