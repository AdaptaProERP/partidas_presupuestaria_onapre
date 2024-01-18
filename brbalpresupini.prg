// Programa   : BRBALPRESUPINI
// Fecha/Hora : 27/04/2021 10:43:29
// Propósito  : "Balance Inicial Valorizado en Divisas"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cNumEje,cCodMon)
   LOCAL aData,aFechas,cFileMem:="USER\BRBALPRESUPINI.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer,dFecha
   LOCAL lConectar:=.F.,cNumIni,aBalance:={}

   oDp:cRunServer:=NIL


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF

   aBalance:=ATABLE("SELECT CPP_CODIGO FROM 	DPCTAPRESUP WHERE LENGTH(CPP_CODIGO)=1")

 
//   AADD(aBalance,oDp:cCtaBg1)
//   AADD(aBalance,oDp:cCtaBg2)
//   AADD(aBalance,oDp:cCtaBg3)

   ADEPURA(aBalance,{|a,n| Empty(a)})

   AADD(aBalance,"")

   DEFAULT cCodSuc :=oDp:cSucursal,;
           cNumEje:=EJECUTAR("FCH_EJERGET",oDp:dFecha),;
           cCodMon:=oDp:cMonedaBcv,;
           dFecha :=SQLGET("DPEJERCICIOS","EJE_DESDE","EJE_CODSUC"+GetWhere("=",cCodSuc)+" AND EJE_NUMERO"+GetWhere("=",cNumEje))

// ? cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cNumEje,cCodMon

   cTitle:="Registro del Presupuesto Inicial Ejercicio "+cNumEje+" "+DTOC(dFecha)

// +IF(Empty(cTitle),"",cTitle)+" "+DTOC(dFecha)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")


   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)

      cCodPar:=ATAIL(_VECTOR(cWhere,"="))

      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF !Empty(cNumEje)
       dDesde:=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA","EJE_NUMERO"+GetWhere("=",cNumEje))
       dHasta:=DPSQLROW(2)
   ENDIF

// ? dDesde,dHasta


/*
   IF .T. .AND. (!nPeriodo=11 .AND. (Empty(dDesde) .OR. Empty(dhasta)))

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF
*/
  
   oDp:cCtaModIni:=SQLGET("DPEJERCICIOS","EJE_CTAMOD","EJE_NUMERO"+GetWhere("=",cNumEje)) // ejercicio Inicial
   oDp:lVacio    :=.F.

   cWhere:=HACERWHERE(dDesde,dHasta,cWhere)
   aData :=LEERDATA(cWhere,NIL,cServer,NIL,NIL,dFecha)

   IF !Empty(cNumEje) .AND. Empty(aData) .OR. Empty(aData[1,1])
      cNumIni:=STRZERO(VAL(cNumEje)-1,4)
      EJECUTAR("DPEJERCICIOBAL_INI",cNumIni)
      aData :=LEERDATA(cWhere,NIL,cServer,NIL,NIL,dFecha   )
   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,cWhere)

   oDp:oFrm:=oBALINIDIV

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD


   DpMdi(cTitle,"oBALINIDIV","BRBALPRESUPINI.EDT")
// oBALINIDIV:CreateWindow(0,0,100,550)
   oBALINIDIV:Windows(0,0,aCoors[3]-160,MIN(752,aCoors[4]-10),.T.) // Maximizado

   oBALINIDIV:cCodSuc  :=cCodSuc
   oBALINIDIV:lMsgBar  :=.F.
   oBALINIDIV:cPeriodo :=aPeriodos[nPeriodo]
   oBALINIDIV:cCodSuc  :=cCodSuc
   oBALINIDIV:nPeriodo :=nPeriodo
   oBALINIDIV:cNombre  :=""
   oBALINIDIV:dDesde   :=dDesde
   oBALINIDIV:dFecha   :=dFecha
   oBALINIDIV:cServer  :=cServer
   oBALINIDIV:dHasta   :=dHasta
   oBALINIDIV:cWhere   :=cWhere
   oBALINIDIV:cWhere_  :=cWhere_
   oBALINIDIV:cWhereQry:=""
   oBALINIDIV:cSql     :=oDp:cSql
   oBALINIDIV:oWhere   :=TWHERE():New(oBALINIDIV)
   oBALINIDIV:cCodPar  :=cCodPar // Código del Parámetro
   oBALINIDIV:lWhen    :=.T.
   oBALINIDIV:cTextTit :="" // Texto del Titulo Heredado
   oBALINIDIV:oDb      :=oDp:oDb
   oBALINIDIV:cBrwCod  :="BALINIDIV"
   oBALINIDIV:lTmdi    :=.T.
   oBALINIDIV:aHead    :={}
   oBALINIDIV:lBarDef  :=.T. // Activar Modo Diseño.
   oBALINIDIV:cCodMon  :=cCodMon
   oBALINIDIV:dFecha   :=dFecha
// oBALINIDIV:nValCam  :=0
// oBALINIDIV:nValCam  :=SQLGET("DPHISMON","HMN_VALOR","HMN_CODIGO"+GetWhere("=",oBALINIDIV:cCodMon)+" AND HMN_FECHA"+GetWhere("=",oBALINIDIV:dFecha))
   oBALINIDIV:nValCam  :=EJECUTAR("DPGETVALCAM",oBALINIDIV:cCodMon,oBALINIDIV:dFecha,"")
   oBALINIDIV:lVacio   :=oDp:lVacio // si esta vacio calculo en BS
   oBALINIDIV:cNumEje  :=cNumEje
   oBALINIDIV:cNumero  :="000000"+cNumEje
   oBALINIDIV:cCtaMod  :=oDp:cCtaModIni
   oBALINIDIV:aBalance :=ACLONE(aBalance)

   // Guarda los parámetros del Browse cuando cierra la ventana
   oBALINIDIV:bValid   :={|| EJECUTAR("BRWSAVEPAR",oBALINIDIV)}

   oBALINIDIV:lBtnRun     :=.F.
   oBALINIDIV:lBtnMenuBrw :=.F.
   oBALINIDIV:lBtnSave    :=.F.
   oBALINIDIV:lBtnCrystal :=.F.
   oBALINIDIV:lBtnRefresh :=.F.
   oBALINIDIV:lBtnHtml    :=.T.
   oBALINIDIV:lBtnExcel   :=.T.
   oBALINIDIV:lBtnPreview :=.T.
   oBALINIDIV:lBtnQuery   :=.F.
   oBALINIDIV:lBtnOptions :=.T.
   oBALINIDIV:lBtnPageDown:=.T.
   oBALINIDIV:lBtnPageUp  :=.T.
   oBALINIDIV:lBtnFilters :=.T.
   oBALINIDIV:lBtnFind    :=.T.

   oBALINIDIV:nClrPane1:=16775408
   oBALINIDIV:nClrPane2:=16771797

   oBALINIDIV:nClrText :=0
   oBALINIDIV:nClrText1:=0
   oBALINIDIV:nClrText2:=0
   oBALINIDIV:nClrText3:=0

   oBALINIDIV:oBrw:=TXBrowse():New( IF(oBALINIDIV:lTmdi,oBALINIDIV:oWnd,oBALINIDIV:oDlg ))
   oBALINIDIV:oBrw:SetArray( aData, .F. )
   oBALINIDIV:oBrw:SetFont(oFont)

   oBALINIDIV:oBrw:lFooter     := .T.
   oBALINIDIV:oBrw:lHScroll    := .F.
   oBALINIDIV:oBrw:nHeaderLines:= 2
   oBALINIDIV:oBrw:nDataLines  := 1
   oBALINIDIV:oBrw:nFooterLines:= 1

   oBALINIDIV:aData            :=ACLONE(aData)

   AEVAL(oBALINIDIV:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  // Campo: ASP_CUENTA
  oCol:=oBALINIDIV:oBrw:aCols[1]
  oCol:cHeader      :='Código'+CRLF+'Partida'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBALINIDIV:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  // Campo: CTA_DESCRI
  oCol:=oBALINIDIV:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBALINIDIV:oBrw:aArrayData ) } 
  oCol:nWidth       := 320

  // Campo: ASP_MTOORG
  oCol:=oBALINIDIV:oBrw:aCols[3]
  oCol:cHeader      :='Monto'+CRLF+'Divisa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBALINIDIV:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,3],;
                              oCol   := oBALINIDIV:oBrw:aCols[3],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[3],oCol:cEditPicture)
  oCol:lTotal       :=.T.

  oCol:nEditType  :=1
  oCol:bOnPostEdit:={|oCol,uValue|oBALINIDIV:PUTMONTO(oCol,uValue,3)}


  oCol:oDataFont:=oFontB


  // Campo: ASP_MONTO
  oCol:=oBALINIDIV:oBrw:aCols[4]
  oCol:cHeader      :='Monto'+CRLF+''+oDp:cMoneda
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBALINIDIV:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,4],;
                              oCol  := oBALINIDIV:oBrw:aCols[4],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[4],oCol:cEditPicture)
  oCol:lTotal       :=.T.

  oCol:nEditType  :=1
  oCol:bOnPostEdit:={|oCol,uValue|oBALINIDIV:PUTMONTOBS(oCol,uValue,4)}

/*


  // Campo: RECALC
  oCol:=oBALINIDIV:oBrw:aCols[5]
  oCol:cHeader      :='Monto'+CRLF+'Recalculado'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBALINIDIV:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,5],;
                              oCol  := oBALINIDIV:oBrw:aCols[5],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[5],oCol:cEditPicture)
  oCol:lTotal       :=.T.


  // Campo: AJUSTE
  oCol:=oBALINIDIV:oBrw:aCols[6]
  oCol:cHeader      :='Monto'+CRLF+'Ajuste'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBALINIDIV:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,6],;
                              oCol  := oBALINIDIV:oBrw:aCols[6],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[6],oCol:cEditPicture)
  oCol:lTotal       :=.T.
*/

  // Campo: CTA_DESCRI
  oCol:=oBALINIDIV:oBrw:aCols[5]
  oCol:cHeader      :='Clasificación'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBALINIDIV:oBrw:aArrayData ) } 
  oCol:nWidth       := 120



   oBALINIDIV:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oBALINIDIV:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oBALINIDIV:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oBALINIDIV:nClrText,;
                                                 nClrText:=IF(.F.,oBALINIDIV:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oBALINIDIV:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oBALINIDIV:nClrPane1, oBALINIDIV:nClrPane2 ) } }

//   oBALINIDIV:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oBALINIDIV:oBrw:bClrFooter            := {|| {0,14671839 }}

   oBALINIDIV:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oBALINIDIV:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oBALINIDIV:oBrw:bLDblClick:={|oBrw|oBALINIDIV:RUNCLICK() }

   oBALINIDIV:oBrw:bChange:={||oBALINIDIV:BRWCHANGE()}
   oBALINIDIV:oBrw:CreateFromCode()


   oBALINIDIV:oWnd:oClient := oBALINIDIV:oBrw



   oBALINIDIV:Activate({||oBALINIDIV:ViewDatBar()})

   oBALINIDIV:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oBALINIDIV:lTmdi,oBALINIDIV:oWnd,oBALINIDIV:oDlg)
   LOCAL nLin:=2,nCol:=0,I
   LOCAL nWidth:=oBALINIDIV:oBrw:nWidth()

   oBALINIDIV:oBrw:GoBottom(.T.)
   oBALINIDIV:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRBALPRESUPINI.EDT")
//     oBALINIDIV:oBrw:Move(44,0,752+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD


 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oBALINIDIV:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oBALINIDIV:oBrw,oBALINIDIV:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

/*  
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oBALINIDIV:CALCULARDIV()

   oBtn:cToolTip:="Calcular Según Valor de la Divisa"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\mayoranalitico.BMP";
          ACTION oBALINIDIV:MAYOR()

    oBtn:cToolTip:="Mayor Analítico"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\balancecomprobacion.BMP";
          ACTION oBALINIDIV:BALCOM()

   oBtn:cToolTip:="Balance de Comprobación"

*/

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XDELETE.BMP";
          ACTION oBALINIDIV:DELBALINI()

  oBtn:cToolTip:="Remover Balance Inicial"


/*
   IF Empty(oBALINIDIV:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","BALINIDIV")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","BALINIDIV"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oBALINIDIV:oBrw,"BALINIDIV",oBALINIDIV:cSql,oBALINIDIV:nPeriodo,oBALINIDIV:dDesde,oBALINIDIV:dHasta,oBALINIDIV)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oBALINIDIV:oBtnRun:=oBtn



       oBALINIDIV:oBrw:bLDblClick:={||EVAL(oBALINIDIV:oBtnRun:bAction) }


   ENDIF




IF oBALINIDIV:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oBALINIDIV");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oBALINIDIV:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF


IF oBALINIDIV:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oBALINIDIV:oBrw,oBALINIDIV:oFrm)
ENDIF

IF oBALINIDIV:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oBALINIDIV),;
                  EJECUTAR("DPBRWMENURUN",oBALINIDIV,oBALINIDIV:oBrw,oBALINIDIV:cBrwCod,oBALINIDIV:cTitle,oBALINIDIV:aHead));
          WHEN !Empty(oBALINIDIV:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oBALINIDIV:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oBALINIDIV:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oBALINIDIV:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oBALINIDIV:oBrw,oBALINIDIV);
          ACTION EJECUTAR("BRWSETFILTER",oBALINIDIV:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oBALINIDIV:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oBALINIDIV:oBrw);
          WHEN LEN(oBALINIDIV:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oBALINIDIV:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oBALINIDIV:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oBALINIDIV:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oBALINIDIV)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oBALINIDIV:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oBALINIDIV:oBrw,oBALINIDIV:cTitle,oBALINIDIV:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oBALINIDIV:oBtnXls:=oBtn

ENDIF

IF oBALINIDIV:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oBALINIDIV:HTMLHEAD(),EJECUTAR("BRWTOHTML",oBALINIDIV:oBrw,NIL,oBALINIDIV:cTitle,oBALINIDIV:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oBALINIDIV:oBtnHtml:=oBtn

ENDIF


IF oBALINIDIV:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oBALINIDIV:oBrw))

   oBtn:cToolTip:="Previsualización"

   oBALINIDIV:oBtnPreview:=oBtn

ENDIF

   IF .T. 

// ISSQLGET("DPREPORTES","REP_CODIGO","BRBALPRESUPINI")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oBALINIDIV:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oBALINIDIV:oBtnPrint:=oBtn

   ENDIF

IF oBALINIDIV:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oBALINIDIV:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oBALINIDIV:oBrw:GoTop(),oBALINIDIV:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oBALINIDIV:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oBALINIDIV:oBrw:PageDown(),oBALINIDIV:oBrw:Setfocus())
  ENDIF

  IF  oBALINIDIV:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oBALINIDIV:oBrw:PageUp(),oBALINIDIV:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oBALINIDIV:oBrw:GoBottom(),oBALINIDIV:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oBALINIDIV:Close()

  oBALINIDIV:oBrw:SetColor(0,oBALINIDIV:nClrPane1)

  oBALINIDIV:SETBTNBAR(40,40,oBar)

  EVAL(oBALINIDIV:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  nCol:=32
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),nCol:=nCol+o:nWidth()})

  oBar:SetSize(NIL,80,.T.)

  oBALINIDIV:oBar:=oBar

  nLin:=2
//  nCol:=470+10+15+20+32+32


  @ nLin+0,nCol+60 BMPGET oBALINIDIV:oCodMon  VAR oBALINIDIV:cCodMon;
                 PIXEL;
                 NAME "BITMAPS\Calendar.bmp";
                 ACTION (oDpLbx:=DpLbx("DPTABMON",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oBALINIDIV:oCodMon,NIL),;
                         oDpLbx:GetValue("MON_CODIGO",oBALINIDIV:oCodMon));
                 VALID oAVINOTENTDET:VALCODMON();
                 SIZE 40,20;
                 WHEN oBALINIDIV:lWhen ;
                 OF oBar;
                 FONT oFont

  oBALINIDIV:oCodMon:bLostFocus:={|| oBALINIDIV:VALCODMON()}

  @ oBALINIDIV:oCodMon:nTop,nCol-55+60 SAY oDp:xDPTABMON+" " OF oBar BORDER SIZE 54,20 PIXEL;
                               BORDER RIGHT COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

  @ oBALINIDIV:oCodMon:nTop,nCol+60+60 SAY oBALINIDIV:oSayCodMon PROMPT " "+SQLGET("DPTABMON","MON_DESCRI","MON_CODIGO"+GetWhere("=",oBALINIDIV:cCodMon));
                                       OF oBar PIXEL SIZE 220+40,20 BORDER COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont


  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14 BOLD

  @ oBALINIDIV:oCodMon:nTop+21,nCol-60+4+60 SAY oBALINIDIV:oSayValCam PROMPT TRAN(oBALINIDIV:nValCam,oDp:cPictValCam);
                                       OF oBar PIXEL SIZE 220,20 BORDER COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont RIGHT

//  @ oBALINIDIV:oCodMon:nTop+20,nCol+60+60 SAY oBALINIDIV:oSayValCam PROMPT TRAN(SQLGET("DPHISMON","HMN_VALOR","HMN_CODIGO"+GetWhere("=",oBALINIDIV:cCodMon)+" AND HMN_FECHA"+GetWhere("=",oBALINIDIV:dFecha)),"99,999,999,999.99");
//                                       OF oBar PIXEL SIZE 220,20 BORDER COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont RIGHT

  BMPGETBTN(oBALINIDIV:oCodMon,oFont,13)

  FOR I=1 TO LEN(oBALINIDIV:aBalance)

     @ 44,20+(35*(I-1)) BUTTON oBtn PROMPT oBALINIDIV:aBalance[I] SIZE 27,24;
                        FONT oFont;
                        OF oBar;
                        PIXEL;
                        ACTION (1=1)

     oBtn:bAction:=BloqueCod([oBALINIDIV:BUSCARLETRA(]+GetWhere("",oBALINIDIV:aBalance[I])+[)])
     oBtn:CARGO:=oBALINIDIV:aBalance[I]

     IF Empty(oBALINIDIV:aBalance[I])
       oBtn:cToolTip:="Restaurar Todas las Cuentas"
     ELSE
       oBtn:cToolTip:="Filtrar Cuentas que empiecen con Dígito "+oBALINIDIV:aBalance[I]
     ENDIF

  NEXT I
//

//  @ 44,20    BUTTON oBALINIDIV:aBalance[1] ACTION MsgMemo("UNO") OF oBar PIXEL SIZE 30,30 FONT oFont
//  @ 44,20+35 BUTTON oBALINIDIV:aBalance[2] ACTION MsgMemo("UNO") OF oBar PIXEL SIZE 30,30 FONT oFont
//  @ 44,20+70 BUTTON oBALINIDIV:aBalance[3] ACTION MsgMemo("UNO") OF oBar PIXEL SIZE 30,30 FONT oFont

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})

//  oBALINIDIV:VALCODMON()
// ? oBALINIDIV:nValCam,"oBALINIDIV:nValCam"

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()


RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere:=NIL

  oRep:=REPORTE("BALANCEGEN",cWhere)
  oRep:cSql  :=oBALINIDIV:cSql
  oRep:cTitle:=oBALINIDIV:cTitle

  oRep:SETCRITERIO(1,oBALINIDIV:dDesde)

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oBALINIDIV:oPeriodo:nAt,cWhere
/*
  oBALINIDIV:nPeriodo:=nPeriodo


  IF oBALINIDIV:oPeriodo:nAt=LEN(oBALINIDIV:oPeriodo:aItems)

     oBALINIDIV:oDesde:ForWhen(.T.)
     oBALINIDIV:oHasta:ForWhen(.T.)
     oBALINIDIV:oBtn  :ForWhen(.T.)

     DPFOCUS(oBALINIDIV:oDesde)

  ELSE

     oBALINIDIV:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oBALINIDIV:oDesde:VarPut(oBALINIDIV:aFechas[1] , .T. )
     oBALINIDIV:oHasta:VarPut(oBALINIDIV:aFechas[2] , .T. )

     oBALINIDIV:dDesde:=oBALINIDIV:aFechas[1]
     oBALINIDIV:dHasta:=oBALINIDIV:aFechas[2]

     cWhere:=oBALINIDIV:HACERWHERE(oBALINIDIV:dDesde,oBALINIDIV:dHasta,oBALINIDIV:cWhere,.T.)

     oBALINIDIV:LEERDATA(cWhere,oBALINIDIV:oBrw,oBALINIDIV:cServer,oBALINIDIV)

  ENDIF

  oBALINIDIV:SAVEPERIODO()
*/

RETURN .T.

FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPASIENTOSPRE.ASP_FECHA"$cWhere
     RETURN ""
   ENDIF

/*   
   IF !Empty(dDesde)
       cWhere:= "DPASIENTOSPRE.ASP_FECHA           "+GetWhere("<=",dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:= "DPASIENTOSPRE.ASP_FECHA           "+GetWhere("<=",dHasta)
     ENDIF
   ENDIF
*/

   IF !Empty(dDesde) .AND. !Empty(dHasta)
     cWhere:= GetWhereAnd("DPASIENTOSPRE.ASP_FECHA",dDesde,dHasta)
   ENDIF

   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oCTARESSLD:cWhereQry)
       cWhere:=cWhere + oBALINIDIV:cWhereQry
     ENDIF

     oBALINIDIV:LEERDATA(cWhere,oBALINIDIV:oBrw,oBALINIDIV:cServer,oBALINIDIV)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oBALINIDIV,nValCam,dFecha)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb
   LOCAL nAt,nRowSel

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

   cWhere:=IIF(Empty(cWhere),"",ALLTRIM(cWhere))

   IF !Empty(cWhere) .AND. LEFT(cWhere,5)="WHERE"
      cWhere:=SUBS(cWhere,6,LEN(cWhere))
   ENDIF

   cSql:=" SELECT  "+;
         "  ASP_CODCTA, "+;
         "  ASP_DESCRI, "+;
         "  SUM(IF(dpasientospre.ASP_MTOORG IS NULL OR ASP_MTOORG=0,dpasientospre.ASP_MONTO/ASP_VALCAM,dpasientospre.ASP_MTOORG)) AS ASP_MTOORG, "+;
         "  SUM(ASP_MONTO) AS ASP_MONTO, "+;
         "  0 AS RECALC,"+;
         "  0 AS AJUSTE,CTA_PROPIE "+;
         "  FROM "+;
         "  DPASIENTOSPRE "+;
         "  INNER JOIN DPCTAPRESUP  ON ASP_CTAMOD=CPP_CTAMOD AND ASP_CODCTA=CPP_CODIGO "+;
         "  WHERE ASP_CODSUC=&oDp:cSucursal AND ASP_ORIGEN='INI' "+;
         "  GROUP BY ASP_CODCTA "+;
         ""

/*
   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF
*/
   IF !Empty(cWhere)
      cSql:=EJECUTAR("SQLINSERTWHERE",cSql,cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRBALPRESUPINI.SQL",cSql)

   aData:={} // ASQL(cSql,oDb)

   IF Empty(aData) 

    oDp:lVacio:=.T.

    cSql:=" SELECT  "+;
          " CPP_CODIGO, "+;
          " CPP_DESCRI, "+;
          " dpasientospre.ASP_MTOORG, "+;
          " dpasientospre.ASP_MONTO, "+;
          " CPP_CLASIF "+;
          " FROM "+;
          " DPCTAPRESUP  "+;
          " LEFT JOIN dpasientospre ON ASP_CTAMOD=CPP_CTAMOD AND ASP_CODCTA=CPP_CODIGO AND ASP_FECHA"+GetWhere("=",dFecha)+;
          " WHERE CPP_CTAMOD"+GetWhere("=",oDp:cCtaModIni)+" AND CPP_TIPO"+GetWhere("=","D")+;
          " GROUP BY CPP_CODIGO "+;
          ""

     aData:=ASQL(cSql,oDb)

   ENDIF

   oDp:cWhere:=cWhere

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',0,0,0,0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oBALINIDIV:cSql   :=cSql
      oBALINIDIV:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      // oBrw:nArrayAt  :=1
      // oBrw:nRowSel   :=1

      // JN 15/03/2020 Sustituido por BRWCALTOTALES
      EJECUTAR("BRWCALTOTALES",oBrw,.F.)

      nAt    :=oBrw:nArrayAt
      nRowSel:=oBrw:nRowSel

      oBrw:Refresh(.F.)
      oBrw:nArrayAt  :=MIN(nAt,LEN(aData))
      oBrw:nRowSel   :=MIN(nRowSel,oBrw:nRowSel)
      AEVAL(oBALINIDIV:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oBALINIDIV:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRBALPRESUPINI.MEM",V_nPeriodo:=oBALINIDIV:nPeriodo
  LOCAL V_dDesde:=oBALINIDIV:dDesde
  LOCAL V_dHasta:=oBALINIDIV:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oBALINIDIV)
RETURN .T.

/*
// Ejecución Cambio de Linea
*/
FUNCTION BRWCHANGE()
RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere


    IF Type("oBALINIDIV")="O" .AND. oBALINIDIV:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oBALINIDIV:cWhere_),oBALINIDIV:cWhere_,oBALINIDIV:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oBALINIDIV:LEERDATA(oBALINIDIV:cWhere_,oBALINIDIV:oBrw,oBALINIDIV:cServer)
      oBALINIDIV:oWnd:Show()
      oBALINIDIV:oWnd:Restore()

    ENDIF

RETURN NIL

FUNCTION BTNRUN()
    ? "PERSONALIZA FUNCTION DE BTNRUN"
RETURN .T.

FUNCTION BTNMENU(nOption,cOption)

   ? nOption,cOption,"PESONALIZA LAS SUB-OPCIONES"

   IF nOption=1
   ENDIF

   IF nOption=2
   ENDIF

   IF nOption=3
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oBALINIDIV:aHead:=EJECUTAR("HTMLHEAD",oBALINIDIV)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oBALINIDIV)
RETURN .T.

/*
// Genera Correspondencia Masiva
*/

FUNCTION VALCODMON(lRefresh)


   DEFAULT lRefresh:=.F.
 
   oBALINIDIV:nValCam:=SQLGET("DPHISMON","HMN_VALOR","HMN_CODIGO"+GetWhere("=",oBALINIDIV:cCodMon)+" AND HMN_FECHA"+GetWhere("=",oBALINIDIV:dFecha))

   oBALINIDIV:oSayCodMon:Refresh(.T.) 
   oBALINIDIV:oSayValCam:Refresh(.T.)

// ? oDp:cSql,oBALINIDIV:cCodMon,oBALINIDIV:dFecha
 
   IF !ISSQLFIND("DPTABMON","MON_CODIGO"+GetWhere("=",oBALINIDIV:cCodMon))
      EVAL(oBALINIDIV:oCodMon:bAction)
      RETURN .F.
   ENDIF

   IF lRefresh
     oBALINIDIV:HACERWHERE(oBALINIDIV:dDesde,oBALINIDIV:dHasta,oBALINIDIV:cWhere,.T.)
   ENDIF

RETURN .T.


FUNCTION PUTMONTO(oCol,uValue,nCol,nAt,lRefresh)
  LOCAL aLine   :=oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt]
  LOCAL aTotales:={}
  LOCAL cWhere
  LOCAL nValCam :=IF(oBALINIDIV:nValCam=0,aLine[4]/uValue,oBALINIDIV:nValCam)
  LOCAL oDb     :=OpenOdbc(oDp:cDsnData),cSql
  LOCAL nMontoBs:=0

  DEFAULT lRefresh:=.T.,;
          nAt     :=oBALINIDIV:oBrw:nArrayAt

  oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,nCol]:=uValue

  IF oBALINIDIV:lVacio
    oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,4   ]:=ROUND(uValue*oBALINIDIV:nValCam,2)
//    oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,6   ]:=0
  ELSE
//    oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,5   ]:=ROUND(uValue*oBALINIDIV:nValCam,2)
//    oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,6   ]:=oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,5]-oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,4]
  ENDIF

  nMontoBs:=oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,4   ]

  EJECUTAR("BRWCALTOTALES",oBALINIDIV:oBrw,.F.)

  oBALINIDIV:oBrw:DrawLine(.T.)

  cSql:=" SET FOREIGN_KEY_CHECKS = 0"
  oDb:Execute(cSql)

  cWhere:="CPC_CODSUC"+GetWhere("=",oBALINIDIV:cCodSuc)+" AND "+;
          "CPC_ACTUAL"+GetWhere("=","S"               )+" AND "+;
          "CPC_NUMERO"+GetWhere("=",oBALINIDIV:cNumero)+" AND "+;
          "CPC_FECHA" +GetWhere("=",oBALINIDIV:dFecha )

  IF !ISSQLFIND("DPCBTEPRESUP",cWhere)

       EJECUTAR("CREATERECORD","DPCBTEPRESUP",{"CPC_CODSUC"      ,"CPC_ACTUAL","CPC_NUMERO","CPC_FECHA","CPC_NUMEJE"      ,"CPC_TITULO"     ,"CPC_CENCOS"},;
                                              {oBALINIDIV:cCodSuc,"S"         ,oBALINIDIV:cNumero      ,oBALINIDIV:dFecha,oBALINIDIV:cNumEje,"Balance Inicial",oDp:cCenCos},;
       NIL,.T.,cWhere)

  ENDIF


  cWhere:="ASP_CODSUC"+GetWhere("=",oBALINIDIV:cCodSuc)+" AND "+;
          "ASP_CODCTA"+GetWhere("=",aLine[1]          )+" AND "+;
          "ASP_ACTUAL"+GetWhere("=","S"               )+" AND "+;
          "ASP_ORIGEN"+GetWhere("=","BAL"             )+" AND "+;
          "ASP_FECHA" +GetWhere("=",oBALINIDIV:dFecha )

  EJECUTAR("CREATERECORD","DPASIENTOSPRE",{"ASP_CODCTA","ASP_CODSUC"      ,"ASP_ACTUAL","ASP_NUMERO","ASP_FECHA"       ,"ASP_NUMEJE"      ,;
                                           "ASP_DESCRI","ASP_VALCAM"      ,"ASP_MTOORG","ASP_CODMON","ASP_CTAMOD"       ,"ASP_MONTO" ,"ASP_ORIGEN","ASP_TIPO"},;
                                       {aLine[1]    ,oBALINIDIV:cCodSuc,"S"         ,oBALINIDIV:cNumero ,oBALINIDIV:dFecha,oBALINIDIV:cNumEje,;
                                       "Presupuesto Inicial",oBALINIDIV:nValCam,uValue,oBALINIDIV:cCodMon,oBALINIDIV:cCtaMod,nMontoBs,"BAL","PI"},;
          NIL,.T.,cWhere)

  cSql:=" SET FOREIGN_KEY_CHECKS = 1"
  oDb:Execute(cSql)

/*
  IF !Empty(oBALINIDIV:cWhere_)
     cWhere:=cWhere+" AND "+oBALINIDIV:cWhere_
  ENDIF

  SQLUPDATE("DPASIENTOSPRE",{"ASP_VALCAM","ASP_MTOORG","ASP_CODMON"      },; 
                         {nValCam     ,uValue      ,oBALINIDIV:cCodMon},cWhere)
*/

//,oBALINIDIV:cWhere_ 


/*
  cWhere:="HMN_CODIGO"+GetWhere("=",oBALINIDIV:cCodMon)+" AND "+;
          "HMN_FECHA "+GetWhere("=",aLine[1])

  EJECUTAR("CREATERECORD","DPHISMON",{"HMN_CODIGO"         ,"HMN_FECHA","HMN_VALOR"},; 
                                     {oBALINIDIV:cCodMon,aLine[1]   ,uValue     },;
                                     NIL,.T.,cWhere)
*/   
RETURN .T.
/*
// Calcular Segun Valor de la Divisa
*/
FUNCTION CALCULARDIV()
  LOCAL I,uValue

  FOR I=1 TO LEN(oBALINIDIV:oBrw:aArrayData)

    uValue:= oBALINIDIV:oBrw:aArrayData[I,04]/oBALINIDIV:nValCam
    oBALINIDIV:oBrw:aArrayData[I,03]:=uValue
//    oBALINIDIV:oBrw:aArrayData[I,05]:=uValue*oBALINIDIV:nValCam
//    oBALINIDIV:oBrw:aArrayData[I,06]:=oBALINIDIV:oBrw:aArrayData[I,5]-oBALINIDIV:oBrw:aArrayData[I,4]

  NEXT I

  EJECUTAR("BRWCALTOTALES",oBALINIDIV:oBrw,.T.)

RETURN .T.

FUNCTION DELBALINI()
   ? "REMOVER BALANCE INICIAL"
RETURN .T.

FUNCTION MAYOR()
  LOCAL RGO_C1:=oBALINIDIV:cCodSuc,RGO_C2:=NIL,RGO_C3:=NIL,RGO_C4:=NIL,RGO_I1:=SPACE(20),RGO_F1:=SPACE(20),RGO_I2:=NIL,RGO_F2:=NIL

RETURN EJECUTAR("BRWMAYORANALITICO",NIL,oDp:dFchInicio,oDp:dFchCierre,RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_I1,RGO_F1,RGO_I2,RGO_F2)

FUNCTION BALCOM()
  LOCAL oGenRep:=NIL,dDesde:=oBALINIDIV:dDesde,dHasta:=oBALINIDIV:dHasta,RGO_C3:=NIL,RGO_C4:=NIL,RGO_C6:=NIL,RGO_I1:=NIL,RGO_F1:=NIL,RGO_I2:=SPACE(20),RGO_F2:=SPACE(20),cCodMon:=NIL

RETURN EJECUTAR("BRWCOMPROBACION",oGenRep,dDesde,dHasta,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon)


FUNCTION PUTMONTOBS(oCol,uValue,nCol,nAt,lRefresh)
  
  oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,nCol  ]:=uValue
  oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,3     ]:=ROUND(uValue/oBALINIDIV:nValCam,2)

//oBALINIDIV:oBrw:DrawLine(.T.)

  oCol:=oBALINIDIV:oBrw:aCols[3]
  oBALINIDIV:PUTMONTO(oCol,oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,3],3)

RETURN .T.


FUNCTION BUSCARLETRA(cLetra)
   LOCAL oBrw:=oBALINIDIV:oBrw
   LOCAL oCol:=oBALINIDIV:oBrw:aCols[1]
   LOCAL uValue:=IF(Empty(cLetra),"","%")+cLetra,nLastKey,lExact

   IF Empty(oBrw:aData)
     oBrw:aData     :=ACLONE(oBrw:aArrayData)
     oBrw:lSetFilter:=.F.
   ENDIF

   oBrw:nColSel:=1
  
   EJECUTAR("BRWFILTER",oCol,uValue,nLastKey,lExact)

RETURN .T.

// EOF
