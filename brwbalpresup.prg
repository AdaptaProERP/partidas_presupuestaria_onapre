// Programa   : BRWBALPRESUP
// Fecha/Hora : 08/05/2021 08:52:05
// Propósito  : Balance Presupuestario
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep,dDesde,dHasta,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon)
  LOCAL aData
  LOCAL aNumEje:={}
  LOCAL cTitle:="Estado de Situación Presupuestario"
  LOCAL cWhere:=NIL
  LOCAL cNumEje
  LOCAL cServer,cCodPar,aTotal:={},aTotal1:={}


  IF Type("oBrBalPresup")="O" .AND. oBrBalPresup:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oBrBalPresup,GetScript())
  ENDIF

  // Solo Ejercicios con Cbte contables
  aNumEje:=ATABLE(" SELECT EJE_NUMERO FROM DPEJERCICIOS "+;
                  " INNER JOIN DPCBTE ON EJE_CODSUC=CBT_CODSUC AND EJE_NUMERO=CBT_NUMEJE "+;
                  " WHERE EJE_CODSUC"+GetWhere("=",oDp:cSucursal)+" GROUP BY EJE_NUMERO ORDER BY EJE_NUMERO ")



  DEFAULT dDesde:=oDp:dFchInicio,;
          dHasta:=oDp:dFchCierre

  DEFAULT RGO_C3:=8,;
          RGO_C4:="999,999,999,999,999.99",;
          RGO_C6:=NIL,;
          RGO_I1:="",;
          RGO_F1:="",;
          RGO_I2:="",;
          RGO_F2:=""

  PUBLICO("RGO_C7","")

//? RGO_I1,"<-RGO_I1",RGO_F1,"<-RGO_F1"
//? oGenRep,dDesde,dHasta,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon,"oGenRep,dDesde,dHasta,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon"

  cNumEje:=EJECUTAR("GETNUMEJE",dDesde)

// ? dDesde,dHasta,NIL,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,"dDesde,dHasta,NIL,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2"

  aData:=HACERBALANCE(dDesde,dHasta,NIL,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2)
  
  oDp:aBalCom:={}


  IF Empty(aData)
     MensajeErr("Balance no Generado")
     RETURN {}
  ENDIF

  aTotal:=aData[LEN(aData)-1]

  ViewData(aData,cTitle,cWhere)

  oDp:aBalCom:=ACLONE(aData)

RETURN aData

FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol
//,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )
   LOCAL nPeriodo:=10,cCodSuc:=oDp:cSucursal

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oBrBalPresup","BRWBALPRESUPUESTARIO.EDT")
// oBrBalPresup:CreateWindow(0,0,100,550)
   oBrBalPresup:Windows(0,0,aCoors[3]-160,aCoors[4]-10,.T.) // Maximizado

   oBrBalPresup:cCodSuc  :=cCodSuc
   oBrBalPresup:lMsgBar  :=.F.
   oBrBalPresup:cPeriodo :=aPeriodos[nPeriodo]
   oBrBalPresup:cCodSuc  :=cCodSuc
   oBrBalPresup:nPeriodo :=nPeriodo
   oBrBalPresup:cNombre  :=""
   oBrBalPresup:dDesde   :=dDesde
   oBrBalPresup:cServer  :=cServer
   oBrBalPresup:dHasta   :=dHasta
   oBrBalPresup:cWhere   :=cWhere
   oBrBalPresup:cWhere_  :=cWhere_
   oBrBalPresup:cWhereQry:=""
   oBrBalPresup:cSql     :=oDp:cSql
   oBrBalPresup:oWhere   :=TWHERE():New(oBrBalPresup)
   oBrBalPresup:cCodPar  :=cCodPar // Código del Parámetro
   oBrBalPresup:lWhen    :=.T.
   oBrBalPresup:cTextTit :="" // Texto del Titulo Heredado
   oBrBalPresup:oDb     :=oDp:oDb
   oBrBalPresup:cBrwCod  :=""
   oBrBalPresup:lTmdi    :=.T.
   oBrBalPresup:aNumEje  :=ACLONE(aNumEje)
   oBrBalPresup:cNumEje  :=cNumEje
   oBrBalPresup:cCodMon  :=cCodMon


   oBrBalPresup:RGO_C3:=RGO_C3
   oBrBalPresup:RGO_C4:=RGO_C4
   oBrBalPresup:RGO_C6:=RGO_C6
   oBrBalPresup:RGO_I1:=RGO_I1
   oBrBalPresup:RGO_F1:=RGO_F1
   oBrBalPresup:RGO_I2:=RGO_I2
   oBrBalPresup:RGO_F2:=RGO_F2

   oBrBalPresup:oBrw:=TXBrowse():New( IF(oBrBalPresup:lTmdi,oBrBalPresup:oWnd,oBrBalPresup:oDlg ))
   oBrBalPresup:oBrw:SetArray( aData, .F. )
   oBrBalPresup:oBrw:SetFont(oFont)

   oBrBalPresup:oBrw:lFooter     := .T.
   oBrBalPresup:oBrw:lHScroll    := .F.
   oBrBalPresup:oBrw:nHeaderLines:= 2
   oBrBalPresup:oBrw:nDataLines  := 1
   oBrBalPresup:oBrw:nFooterLines:= 1

   oBrBalPresup:aData            :=ACLONE(aData)
   oBrBalPresup:nClrText :=0
   oBrBalPresup:nClrPane1:=16772829
   oBrBalPresup:nClrPane2:=16771022


   oBrBalPresup:nClrPane3:=CLR_HRED
   oBrBalPresup:nClrPane4:=CLR_HBLUE
   oBrBalPresup:nClrPane5:=4227072



   AEVAL(oBrBalPresup:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oBrBalPresup:oBrw:aCols[1]
   oCol:cHeader      :='Código'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalPresup:oBrw:aArrayData ) } 
   oCol:nWidth       := 110

   oCol:=oBrBalPresup:oBrw:aCols[2]
   oCol:cHeader      :='Descripción'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalPresup:oBrw:aArrayData ) } 
   oCol:nWidth       :=280

   oCol:=oBrBalPresup:oBrw:aCols[3]
   oCol:cHeader      :='Presupuestado'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalPresup:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='999,999,999,999.99'
   oCol:cFooter      :=aTotal[3]
   oCol:bClrStd      :={|oBrw,nClrText,cMonto|oBrw    :=oBrBalPresup:oBrw,;
                                              cMonto  :=oBrBalPresup:oBrw:aArrayData[oBrBalPresup:oBrw:nArrayAt,3],;
                                              nClrText:=IF("--"$cMonto .OR. "="$cMonto,oBrBalPresup:nClrText,oBrBalPresup:nClrPane4),;
                                              nClrText:=IF("-"$cMonto .AND. !("--"$cMonto .OR. "="$cMonto),oBrBalPresup:nClrPane3,oBrBalPresup:nClrPane4),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalPresup:nClrPane1,oBrBalPresup:nClrPane2 ) } }




   oCol:=oBrBalPresup:oBrw:aCols[4]
   oCol:cHeader      :='Comprometido'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalPresup:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cEditPicture :='999,999,999,999.99'
   oCol:cFooter      :=aTotal[4]

   oCol:bClrStd      :={|oBrw,nClrText,cMonto|oBrw    :=oBrBalPresup:oBrw,;
                                              cMonto  :=oBrBalPresup:oBrw:aArrayData[oBrBalPresup:oBrw:nArrayAt,4],;
                                              nClrText:=IF("--"$cMonto .OR. "="$cMonto,oBrBalPresup:nClrText,oBrBalPresup:nClrPane4),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalPresup:nClrPane1,oBrBalPresup:nClrPane2 ) } }



   oCol:=oBrBalPresup:oBrw:aCols[5]
   oCol:cHeader      :='Ejecutado'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalPresup:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='999,999,999,999.99'
   oCol:cFooter      :=aTotal[5]

   oCol:bClrStd      :={|oBrw,nClrText,cMonto|oBrw    :=oBrBalPresup:oBrw,;
                                              cMonto  :=oBrBalPresup:oBrw:aArrayData[oBrBalPresup:oBrw:nArrayAt,5],;
                                              nClrText:=IF("--"$cMonto .OR. "="$cMonto,oBrBalPresup:nClrText,oBrBalPresup:nClrPane3),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalPresup:nClrPane1,oBrBalPresup:nClrPane2 ) } }



   oCol:=oBrBalPresup:oBrw:aCols[6]
   oCol:cHeader      :='Disponible'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalPresup:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='999,999,999,999.99'
   oCol:cFooter      :=aTotal[6]


   oCol:=oBrBalPresup:oBrw:aCols[7]
   oCol:cHeader      :='Tipo'+CRLF+"Col"

   oCol:=oBrBalPresup:oBrw:aCols[8]
   oCol:cHeader      :='#'+CRLF+"Col"
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 

   oBrBalPresup:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oBrBalPresup:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oBrBalPresup:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oBrBalPresup:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalPresup:nClrPane1, oBrBalPresup:nClrPane2 ) } }

   oBrBalPresup:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oBrBalPresup:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oBrBalPresup:oBrw:bLDblClick:={|oBrw|oBrBalPresup:RUNCLICK() }

   oBrBalPresup:oBrw:bChange:={||oBrBalPresup:BRWCHANGE()}
   oBrBalPresup:oBrw:CreateFromCode()
   oBrBalPresup:bValid   :={|| EJECUTAR("BRWSAVEPAR",oBrBalPresup)}
   oBrBalPresup:BRWRESTOREPAR()

   oBrBalPresup:oWnd:oClient := oBrBalPresup:oBrw

   oBrBalPresup:Activate({||oBrBalPresup:ViewDatBar()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oBrBalPresup:lTmdi,oBrBalPresup:oWnd,oBrBalPresup:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oBrBalPresup:oBrw:nWidth()

   oBrBalPresup:oBrw:GoBottom(.T.)
   oBrBalPresup:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRDOCPROISLREDI.EDT")
//     oBrBalPresup:oBrw:Move(44,0,850+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND
  
   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6+40 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oBrBalPresup:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oBrBalPresup:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS()
   oBrBalPresup:oBrw:oLbx  :=oBrBalPresup // MDI:GOTFOCUS()


 // Emanager no Incluye consulta de Vinculos

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          TOP PROMPT "Calcular";
          ACTION oBrBalPresup:HACERBALANCE(oBrBalPresup:dDesde,oBrBalPresup:dHasta,oBrBalPresup,oBrBalPresup:RGO_C3,oBrBalPresup:RGO_C4,oBrBalPresup:RGO_C6,oBrBalPresup:RGO_I1,oBrBalPresup:RGO_F1,oBrBalPresup:RGO_I2,oBrBalPresup:RGO_F2)


   oBrBalPresup:oBtn:=oBtn:bAction
 
   oBtn:cToolTip:="Ejecutar Balance"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CONTABILIDAD.BMP";
          TOP PROMPT "Cuenta";
          ACTION oBrBalPresup:VERCTA()

   oBtn:cToolTip:="Consultar Cuentas"
/*

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\mayoranalitico.BMP";
          TOP PROMPT "Mayor";
          ACTION oBrBalPresup:MAYOR()

   oBtn:cToolTip:="Mayor Analítico"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\edodegananciayperdida.bmp";
          TOP PROMPT "Resultado";
          ACTION EJECUTAR("BRWGANANCIAYP",NIL,oBrBalPresup:dDesde,oBrBalPresup:dHasta)

   oBtn:cToolTip:="Estado de ganancias y Pérdidas"

*/

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          TOP PROMPT "Detalles"; 
          ACTION  oBrBalPresup:VERBROWSE()

   oBtn:cToolTip:="Ver Asientos"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          TOP PROMPT "Imprimir"; 
          ACTION  oBrBalPresup:PRINTBALCOM()

   oBtn:cToolTip:="Imprimir Balance de Comprobación"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ZOOM.BMP";
          TOP PROMPT "Zoom";
          ACTION IF(oBrBalPresup:oWnd:IsZoomed(),oBrBalPresup:oWnd:Restore(),oBrBalPresup:oWnd:Maximize())

   oBtn:cToolTip:="Maximizar"



 
   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","DOCPROISLREDI"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oBrBalPresup:oBrw,"DOCPROISLREDI",oBrBalPresup:cSql,oBrBalPresup:nPeriodo,oBrBalPresup:dDesde,oBrBalPresup:dHasta,oBrBalPresup)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oBrBalPresup:oBtnRun:=oBtn



       oBrBalPresup:oBrw:bLDblClick:={||EVAL(oBrBalPresup:oBtnRun:bAction) }


   ENDIF



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar"; 
          ACTION  EJECUTAR("BRWSETFIND",oBrBalPresup:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oBrBalPresup:oBrw,oBrBalPresup);
          TOP PROMPT "Filtrar"; 
          ACTION  EJECUTAR("BRWSETFILTER",oBrBalPresup:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones"; 
          ACTION  EJECUTAR("BRWSETOPTIONS",oBrBalPresup:oBrw);
          WHEN LEN(oBrBalPresup:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

/*
      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             MENU EJECUTAR("BRBTNMENU",{"Opción1","Opción"},"oFrm");
             FILENAME "BITMAPS\MENU.BMP";
             ACTION 1=1;

             oBtn:cToolTip:="Boton con Menu"

*/


IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
            TOP PROMPT "Refrescar"; 
              ACTION  oBrBalPresup:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

/*
  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\cbtediferido.bmp";
          MENU EJECUTAR("BRBTNMENU",{"Según Partida","Visualizar Asientos"},"oBrBalPresup");
          ACTION oBrBalPresup:EDITCBTE()

  oBtn:cToolTip:="Editar Comprobante"




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
            TOP PROMPT "Crystal"; 
              ACTION  EJECUTAR("BRWTODBF",oBrBalPresup)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"
*/

IF .T.
// nWidth>400 

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
              TOP PROMPT "Excel"; 
              ACTION  (EJECUTAR("BRWTOEXCEL",oBrBalPresup:oBrw,oBrBalPresup:cTitle,oBrBalPresup:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oBrBalPresup:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
            TOP PROMPT "Html"; 
              ACTION  (oBrBalPresup:HTMLHEAD(),EJECUTAR("BRWTOHTML",oBrBalPresup:oBrw,NIL,oBrBalPresup:cTitle,oBrBalPresup:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oBrBalPresup:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
            TOP PROMPT "Preview"; 
              ACTION  (EJECUTAR("BRWPREVIEW",oBrBalPresup:oBrw))

   oBtn:cToolTip:="Previsualización"

   oBrBalPresup:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRDOCPROISLREDI")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oBrBalPresup:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oBrBalPresup:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oBrBalPresup:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
            TOP PROMPT "Primero"; 
              ACTION  (oBrBalPresup:oBrw:GoTop(),oBrBalPresup:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance"; 
              ACTION  (oBrBalPresup:oBrw:PageDown(),oBrBalPresup:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
            TOP PROMPT "Anterior"; 
              ACTION  (oBrBalPresup:oBrw:PageUp(),oBrBalPresup:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
            TOP PROMPT "Ultimo"; 
              ACTION  (oBrBalPresup:oBrw:GoBottom(),oBrBalPresup:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
            TOP PROMPT "Cerrar"; 
              ACTION  oBrBalPresup:Close()

  oBrBalPresup:oBrw:SetColor(0,oBrBalPresup:nClrPane1)

  EVAL(oBrBalPresup:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oBrBalPresup:oBar:=oBar

    nLin:=490

  // Controles se Inician luego del Ultimo Boton
  nLin:=32
  //AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  IF oDp:lBtnText
     oBrBalPresup:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oBrBalPresup:SETBTNBAR(40,40,oBar)
  ENDIF


  //
  // Campo : Periodo
  //

  @ 10+60, nLin COMBOBOX oBrBalPresup:oPeriodo  VAR oBrBalPresup:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oBrBalPresup:LEEFECHAS();
                WHEN oBrBalPresup:lWhen 


  ComboIni(oBrBalPresup:oPeriodo )

  @ 10+60, nLin+103 BUTTON oBrBalPresup:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oBrBalPresup:oPeriodo:nAt,oBrBalPresup:oDesde,oBrBalPresup:oHasta,-1),;
                         EVAL(oBrBalPresup:oBtn:bAction));
                WHEN oBrBalPresup:lWhen 


  @ 10+60, nLin+130 BUTTON oBrBalPresup:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oBrBalPresup:oPeriodo:nAt,oBrBalPresup:oDesde,oBrBalPresup:oHasta,+1),;
                         EVAL(oBrBalPresup:oBtn:bAction));
                WHEN oBrBalPresup:lWhen 


  @ 10+60, nLin+170 BMPGET oBrBalPresup:oDesde  VAR oBrBalPresup:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oBrBalPresup:oDesde ,oBrBalPresup:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oBrBalPresup:oPeriodo:nAt=LEN(oBrBalPresup:oPeriodo:aItems) .AND. oBrBalPresup:lWhen ;
                FONT oFont

   oBrBalPresup:oDesde:cToolTip:="F6: Calendario"

  @ 10+60, nLin+252 BMPGET oBrBalPresup:oHasta  VAR oBrBalPresup:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oBrBalPresup:oHasta,oBrBalPresup:dHasta);
                SIZE 80,23;
                WHEN oBrBalPresup:oPeriodo:nAt=LEN(oBrBalPresup:oPeriodo:aItems) .AND. oBrBalPresup:lWhen ;
                OF oBar;
                FONT oFont

   oBrBalPresup:oHasta:cToolTip:="F6: Calendario"

   @ 10+60, nLin+335 BUTTON oBrBalPresup:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oBrBalPresup:oPeriodo:nAt=LEN(oBrBalPresup:oPeriodo:aItems);
               ACTION oBrBalPresup:HACERWHERE(oBrBalPresup:dDesde,oBrBalPresup:dHasta,oBrBalPresup:cWhere,.T.);
               WHEN oBrBalPresup:lWhen

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})


  @ 10+60,nLin+325+70 COMBOBOX oBrBalPresup:oNumEje  VAR oBrBalPresup:cNumEje;
                ITEMS oBrBalPresup:aNumEje;
                WHEN LEN(oBrBalPresup:aNumEje)>1 OF oBAR PIXEL SIZE 60,NIL;
                ON CHANGE oBrBalPresup:CAMBIAEJERCICIO() FONT oFont

  oBrBalPresup:oNumEje:cMsg    :="Seleccione el Ejercicio"
  oBrBalPresup:oNumEje:cToolTip:="Seleccione el Ejercicio"


RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()

  oBrBalPresup:VERBROWSE()

RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRDOCPROISLREDI",cWhere)
  oRep:cSql  :=oBrBalPresup:cSql
  oRep:cTitle:=oBrBalPresup:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oBrBalPresup:oPeriodo:nAt,cWhere

  oBrBalPresup:nPeriodo:=nPeriodo


  IF oBrBalPresup:oPeriodo:nAt=LEN(oBrBalPresup:oPeriodo:aItems)

     oBrBalPresup:oDesde:ForWhen(.T.)
     oBrBalPresup:oHasta:ForWhen(.T.)
     oBrBalPresup:oBtn  :ForWhen(.T.)

     DPFOCUS(oBrBalPresup:oDesde)

  ELSE

     oBrBalPresup:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oBrBalPresup:oDesde:VarPut(oBrBalPresup:aFechas[1] , .T. )
     oBrBalPresup:oHasta:VarPut(oBrBalPresup:aFechas[2] , .T. )

     oBrBalPresup:dDesde:=oBrBalPresup:aFechas[1]
     oBrBalPresup:dHasta:=oBrBalPresup:aFechas[2]

     cWhere:=oBrBalPresup:HACERWHERE(oBrBalPresup:dDesde,oBrBalPresup:dHasta,oBrBalPresup:cWhere,.T.)

//     oBrBalPresup:LEERDATA(cWhere,oBrBalPresup:oBrw,oBrBalPresup:cServer)

  ENDIF

  oBrBalPresup:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   oBrBalPresup:HACERBALANCE(dDesde,dHasta,oBrBalPresup)

RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRDOCPROISLREDI.MEM",V_nPeriodo:=oBrBalPresup:nPeriodo
  LOCAL V_dDesde:=oBrBalPresup:dDesde
  LOCAL V_dHasta:=oBrBalPresup:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oBrBalPresup)
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


    IF Type("oBrBalPresup")="O" .AND. oBrBalPresup:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oBrBalPresup:cWhere_),oBrBalPresup:cWhere_,oBrBalPresup:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oBrBalPresup:LEERDATA(oBrBalPresup:cWhere_,oBrBalPresup:oBrw,oBrBalPresup:cServer)
      oBrBalPresup:oWnd:Show()
      oBrBalPresup:oWnd:Restore()

    ENDIF

RETURN NIL


FUNCTION BTNMENU(nOption,cOption)

   IF nOption=1 .AND. "Según"$cOption
      RETURN oBrBalPresup:EDITCBTE(.T.,.F.)
   ENDIF

   IF nOption=2 .AND. "Visua"$cOption
      RETURN oBrBalPresup:EDITCBTE(.T.,.T.)
   ENDIF


RETURN .T.

FUNCTION HTMLHEAD()

   oBrBalPresup:aHead:=EJECUTAR("HTMLHEAD",oBrBalPresup)

RETURN

FUNCTION EDITDOCCXP()
   LOCAL aLine  :=oBrBalPresup:oBrw:aArrayData[oBrBalPresup:oBrw:nArrayAt]
   LOCAL cDocOrg:=aLine[14]
   LOCAL cTipDoc:=aLine[1],cCodigo:=aLine[2],cNumero:=aLine[3]

   IF cDocOrg="D"
     RETURN EJECUTAR("DPDOCCXP",cTipDoc,cCodigo,cTipDoc,cNumero)
   ENDIF
   
   IF cDocOrg="C"
     RETURN EJECUTAR("DPDOCPROINV",oDp:cSucursal,cTipDoc,cCodigo,cNumero)
   ENDIF

RETURN .T.

FUNCTION ISLR()
   LOCAL aLine  :=oBrBalPresup:oBrw:aArrayData[oBrBalPresup:oBrw:nArrayAt]
   LOCAL cDocOrg:=aLine[14]
   LOCAL cTipDoc:=aLine[1],cCodigo:=aLine[2],cNumero:=aLine[3]

RETURN EJECUTAR("DPDOCISLR",oDp:cSucursal,cTipDoc,cCodigo,cNumero,NIL, 'C' )

/*
// Visualizar Asientos
*/
FUNCTION EDITCBTE(lNumPar,lView)
  LOCAL cActual
  LOCAL cTipDoc:=oBrBalPresup:oBrw:aArrayData[oBrBalPresup:oBrw:nArrayAt,1]
  LOCAL cCodigo:=oBrBalPresup:oBrw:aArrayData[oBrBalPresup:oBrw:nArrayAt,2]
  LOCAL cNumero:=oBrBalPresup:oBrw:aArrayData[oBrBalPresup:oBrw:nArrayAt,3]
  LOCAL dFecha :=oBrBalPresup:oBrw:aArrayData[oBrBalPresup:oBrw:nArrayAt,5]
  LOCAL cWhereGrid

  DEFAULT lNumPar:=.F.,;
          lView  :=.F.

  oDp:dFchCbt:=CTOD("")

  cActual:=EJECUTAR("DPDOCVIEWCON",oDp:cSucursal,cTipDoc,cCodigo,cNumero,"D",.F.,lView)

  IF lView
    RETURN .T.
  ENDIF

  dFecha :=IF(Empty(oDp:dFchCbt),dFecha,oDp:dFchCbt)
  cNumero:=oDp:cNumCbt

// ? oDp:dFchCbt,"oDp:dFchCbt",oDp:cNumCbt
 

  IF lNumPar
    cWhereGrid:="MOC_NUMPAR"+GetWhere("=",oBrBalPresup:oBrw:aArrayData[oBrBalPresup:oBrw:nArrayAt,18])
//+" AND "+;
//                "MOC_DOCUME"+GetWhere("=",oBrBalPresup:oBrw:aArrayData[oBrBalPresup:oBrw:nArrayAt,03])
  ENDIF

  EJECUTAR("DPCBTE",cActual,cNumero,dFecha,.F.,NIL,cWhereGrid)

RETURN .T.


FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oBrBalPresup)


FUNCTION CAMBIAEJERCICIO()

  oBrBalPresup:dDesde:=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA","EJE_CODSUC"+GetWhere("=",oBrBalPresup:cCodSuc)+" AND EJE_NUMERO"+GetWhere("=",oBrBalPresup:cNumEje))
  oBrBalPresup:dHasta:=DPSQLROW(2,CTOD(""))

  oBrBalPresup:oDesde:Refresh(.T.)
  oBrBalPresup:oHasta:Refresh(.T.)

  oDp:oCursor:=NIL

//? "DEBE REHACER EL BALANCE"

RETURN oBrBalPresup:HACERBALANCE(oBrBalPresup:dDesde,oBrBalPresup:dHasta,oBrBalPresup)

// ? oBrBalPresup:dDesde,oBrBalPresup:dHasta

RETURN .T.

FUNCTION HACERBALANCE(dDesde,dHasta,oBrBalPresup,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2)
  LOCAL oCursor,cCodPar,cServer,aLine
  LOCAL oGenRep:=NIL
  LOCAL RGO_C1,RGO_C2
  
  LOCAL aData :={}

  DEFAULT  dDesde:=oDp:dFchInicio,;
           dHasta:=oDp:dFchCierre

  DEFAULT oDp:oCursor:=NIL

  RGO_C1:=dDesde
  RGO_C2:=dHasta

  IF ValType(oBrBalPresup)="O"

     aLine:=oBrBalPresup:oBrw:aArrayData[oBrBalPresup:oBrw:nArrayAt]

     oBrBalPresup:RGO_I2:=aLine[1]
     oBrBalPresup:RGO_F2:=aLine[1]

     RGO_C3:=oBrBalPresup:RGO_C3
     RGO_C4:=oBrBalPresup:RGO_C4
     RGO_C6:=oBrBalPresup:RGO_C6
     RGO_I1:=oBrBalPresup:RGO_I1
     RGO_F1:=oBrBalPresup:RGO_F1
     RGO_I2:=oBrBalPresup:RGO_I2
     RGO_F2:=oBrBalPresup:RGO_F2

  ENDIF

// ? dDesde,dHasta
  oDp:oCursor:=NIL

  IF !ISPCPRG()
     oDp:oCursor:=NIL
  ENDIF
  
//  ? RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,"RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2"

  IF oDp:oCursor=NIL 

    oCursor:=EJECUTAR("BPCALCULAR",oGenRep,RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2)

    oDp:oCursor:=oCursor

  ELSE

    oCursor:=oDp:oCursor

  ENDIF
 
  oCursor:GoTop()

 

  WHILE !oCursor:EOF()

     IF oCursor:TIPO="R" 
       AADD(aData,{oCursor:CPP_CODIGO,oCursor:TITULO    ,oCursor:MTOPRESUP,oCursor:MTOCOMPRO,oCursor:MTOEJECUT,oCursor:MTOPAGADO,oCursor:TIPO,oCursor:COL})
     ELSE
       AADD(aData,{oCursor:CPP_CODIGO,oCursor:CPP_DESCRI,oCursor:MTOPRESUP,oCursor:MTOCOMPRO,oCursor:MTOEJECUT,oCursor:MTOPAGADO,oCursor:TIPO,oCursor:COL})
     ENDIF

     oCursor:DbSkip()

  ENDDO

  IF ValType(oBrBalPresup)="O"

     IF Empty(aData)
        aData:={}
        AADD(aData,{"","",0,0,0,0,"T"})
     ENDIF

     oBrBalPresup:oBrw:aArrayData:=ACLONE(aData)
     oBrBalPresup:oBrw:nArrayAt:=1
     oBrBalPresup:oBrw:nRowSel :=1
     oBrBalPresup:oBrw:GoTop()
     oBrBalPresup:oBrw:Refresh(.F.)
  ENDIF

// oCursor:Browse()

RETURN aData

FUNCTION VERCTA()
  LOCAL aLine:=oBrBalPresup:oBrw:aArrayData[oBrBalPresup:oBrw:nArrayAt]

  EJECUTAR("DPCTACON",NIL,aLine[1])

RETURN .T.

FUNCTION VERBROWSE()
  LOCAL aLine  :=oBrBalPresup:oBrw:aArrayData[oBrBalPresup:oBrw:nArrayAt]
  LOCAL cCodCta:=ALLTRIM(aLine[1]),nLen:=LEN(cCodCta)
  LOCAL cWhereL:="LEFT(MOC_CUENTA,"+LSTR(LEN(ALLTRIM(cCodCta)))+")"+GetWhere("=",ALLTRIM(cCodCta))
  LOCAL cActual:={"S","C","A"}
  LOCAL lDelete:=NIL,cCodMon:=oBrBalPresup:cCodMon,lSldIni:=.T.
  LOCAL dDesdeA,dHastaA,nPeriodo:=10
  LOCAL dDesde  :=oBrBalPresup:dDesde
  LOCAL dHasta  :=oBrBalPresup:dHasta

  IF Empty(cCodCta) .OR. !ISSQLFIND("DPCTA","CPP_CODIGO"+GetWhere("=",cCodCta))
     RETURN .F.
  ENDIF

  IF oBrBalPresup:oBrw:nColSel=3
     // Buscamos el ejercicio Anterior
     dDesdeA:=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA","EJE_HASTA"+GetWhere("<",oBrBalPresup:dDesde)+" ORDER BY EJE_HASTA DESC LIMIT 1")
     dHastaA:=DPSQLROW(2,dDesdeA)

     IF !Empty(dDesdeA)
        dDesde  :=dDesdeA
        dHasta  :=dHastaA
        nPeriodo:=11
     ENDIF

// ? dDesdeA,dHastaA,CLPCOPY(oDp:cSql)

  ENDIF

  EJECUTAR("BRDPASIENTOS","MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+cWhereL+" AND "+;
                          GetWhereOr("MOC_ACTUAL",cActual),NIL,nPeriodo,dDesde,dHasta,NIL,cCodCta,cActual,lDelete,cCodMon,lSldIni)

// cActual,lDelete,cCodMon,lSldIni


RETURN .T.

/*
// Imprimir Balance de Comprobación
*/
FUNCTION PRINTBALCOM()
  LOCAL oRep:=REPORTE("BALANCECOM")

  oRep:SetCriterio(1,oBrBalPresup:dDesde)
  oRep:SetCriterio(2,oBrBalPresup:dHasta)

RETURN .T.

FUNCTION MAYOR()
  LOCAL aLine:=oBrBalPresup:oBrw:aArrayData[oBrBalPresup:oBrw:nArrayAt]
  LOCAL RGO_C1:=NIL,RGO_C2:=NIL,RGO_C3:=NIL,RGO_C4:=NIL,RGO_I1:=aLine[1],RGO_F1:=aLine[1],RGO_I2:=NIL,RGO_F2:=NIL

RETURN EJECUTAR("BRWMAYORANALITICO",NIL,oBrBalPresup:dDesde,oBrBalPresup:dHasta,RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_I1,RGO_F1,RGO_I2,RGO_F2)
// EOF

