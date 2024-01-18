// Programa    : SGEBTEPRESUP
// Fecha/Hora  : 22/11/2004 23:10:42
// Propósito   : Editar Comprobante de Presupuesto Gubernamental
// Creado Por  : Juan Navas
// Adaptado por: Riztan Gutierrez - Informatica Del Centro, C.A. (MARZO 2007)
// Llamado por : Presupuesto
// Aplicación  : Contabilidad
// Tabla       : DPCBTEPRESUP

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
 LOCAL I,aData:={},oFontG,oGrid,oCol,cSql,oFontB
 LOCAL oFont,cScope,cTitle:=NIL
 LOCAL aItems1:=GETOPTIONS("DPCBTEPRESUP","CPC_TIPO"),;
       aTipos :={"PI","CO","CA","PA","MO","CR"}
 LOCAL aCoors:=GetCoors( GetDesktopWindow() )
 LOCAL nWidth:=800+210,nHeight:=410+200

 DEFAULT cTipo:="PR",;
         cTitle:=GetFromVar("{oDp:DPCBTEPRESUP}")

 
// cTitle:=IIF(cTipo="S","Asientos Contables Actualizados",cTitle)
// cTitle:=IIF(cTipo="A","Asientos de Auditoría"  ,cTitle)

 cScope:=GetWhereAnd("CPC_FECHA",oDp:dFchInicio,oDp:dFchCierre)

 // Font Para el Browse
/*
 IF Empty(oDp:cModeVideo)
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -11 BOLD
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11
 ELSE
*/

   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -13 BOLD
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -13
// ENDIF

 // ErrorSys(.T.)

 oCbte:=DOCENC(cTitle,"oCbte","SGECBTEPRESUP"+oDp:cModeVideo+".EDT")
 // SysRefresh(.T.)
 oCbte:Prepare()
 oCbte:cPreSave :="PRESAVE"
 oCbte:lBar     :=.T.
 oCbte:nBtnStyle:=1
 oCbte:lCbteOk  :=.F.
 oCbte:dFecha   :=CTOD("")
 oCbte:cNumero  :=""
 oCbte:SetScope(cScope)
 oCbte:aTipos   :=ACLONE(aTipos)
 oCbte:cTipo    :=aTipos[1]
              
 oCbte:SetTable("DPCBTEPRESUP","CPC_NUMERO,CPC_TIPO")

 oDp:nDifW:=MAX((aCoors[4]-150)-nWidth,0)
 oDp:nDifH:=MAX((aCoors[3]-040)-nHeight,0)

 oCbte:lAutoSize:=.T.

 IF oCbte:lAutoSize 
    aCoors[4]:=MIN(aCoors[4],1920)
    oCbte:Windows(0,0,aCoors[3]-140,aCoors[4]-30) 
 ELSE
    // oCbte:Windows(0,0,625,1010) 
    oCbte:Windows(0,0,460+IIF(Empty(oDp:cModeVideo),0,160),790+IIF(Empty(oDp:cModeVideo),0,200))
 ENDIF

 oCbte:Repeat("CPC_TIPO,CPC_FECHA")
 oCbte:nDebe   :=0
 oCbte:nHaber  :=0
 oCbte:nTotal  :=0
 oCbte:cTipo   :=cTipo
 oCbte:cList   :="DPCBTEPRESUP.BRW"
 oCbte:lFind   :=.t.
// oCbte:SetMemo("CPC_NUMMEM","Descripción Amplia para el Comprobante Contable")

 @ 2,1 SAY "Número:"

 @ 2,5 GET oCbte:oCPC_NUMERO VAR oCbte:CPC_NUMERO;
       WHEN oCbte:nOption<>0;
       VALID CERO(oCbte:CPC_NUMERO)

 @ 2,1 SAY "Fecha:" 

 @ 3,06 BMPGET oCbte:oCPC_CENCOS VAR oCbte:CPC_CENCOS;
                VALID oCbte:VALCENCOS();
                NAME "BITMAPS\CLIENTE2.BMP";
                ACTION (oDpLbx:=DpLbx("DPCENCOS",NIL,NIL),;
                        oDpLbx:GetValue("CEN_CODIGO",oCbte:oCPC_CENCOS)); 
                WHEN (AccessField("DPCBTEPRESUP","CPC_CENCOS",oCbte:nOption) .AND. oCbte:nOption<>0 );
                SIZE 44,10

 @ 2,15 SAY "Descripción:" 

 @ 3, 1.0 COMBOBOX oCbte:oCPC_TIPO VAR oCbte:CPC_TIPO  ITEMS aItems1;
                     ON CHANGE  oCbte:CPC_TIPO:=oCbte:aTipos[oCbte:oCPC_TIPO:nAt];
                     WHEN (AccessField("DPCBTEPRESUP","CPC_TIPO",oCbte:nOption);
                    .AND. oCbte:nOption!=0)

 COMBOINI(oCbte:oCPC_TIPO)

 @ 3,5 BMPGET oCbte:oCPC_FECHA VAR oCbte:CPC_FECHA;
       WHEN oCbte:nOption<>0;
       VALID oCbte:CBTFECHA();
       NAME "BITMAPS\CALENDAR.BMP"; 
       ACTION LbxDate(oCbte:oCPC_FECHA,oCbte:CPC_FECHA);
       SIZE 48,NIL

 @ 2,20 GET oCbte:oCPC_TITULO VAR oCbte:CPC_TITULO;
        WHEN oCbte:nOption<>0

 @ 2,1 SAY GetFromVar("{oDp:xDPCENCOS}")

 @ 1,10 SAY oCbte:oCta PROMPT "Cuenta:"+SPACE(40)

 @ 2,15 SAY "Tipo:" 

 @ 3,2 SAY oCbte:oCENCOS PROMPT;
       SQLGET("DPCENCOS","CEN_DESCRI","CEN_CODIGO"+GetWhere("=",oCbte:CPC_CENCOS))


 cSql :=" SELECT "+SELECTFROM("DPASIENTOSPRE",.F.)+;
        " ,DPCTAPRESUP.CPP_CODIGO,DPCTAPRESUP.CPP_DESCRI "+;
        " FROM DPASIENTOSPRE "+;
        " INNER JOIN DPCTAPRESUP ON ASP_CODCTA=CPP_CODIGO"

// ? clpcopy(cSql)
  cScope:="ASP_CODSUC"+GetWhere("=",oDp:cSucursal)
  oGrid :=oCbte:GridEdit( "DPASIENTOSPRE" , "CPC_NUMERO", "ASP_NUMERO" , cSql , cScope)

  oGrid:cScript  :="SGECBTEPRESUP"
//  oGrid:aSize    :={130,0,775+5+IIF(Empty(oDp:cModeVideo),0,200),200+15+IIF(Empty(oDp:cModeVideo),0,170)}

  IF oCbte:lAutoSize 
     // oGrid:aSize      := {100.9+20+20,0,aCoors[4]-30,200+30+170}
     oGrid:aSize      := {130,0,aCoors[4]-60,aCoors[3]-390-30} 
  ENDIF

  oGrid:oFontH   :=oFontB
  oGrid:oFont    :=oFont
  oGrid:bWhen    :="!EMPTY(oCbte:CPC_NUMERO)"
  oGrid:bValid   :="!EMPTY(oGrid:ASP_CODCTA)"
  oGrid:bChange  :='.T.'
 // oGrid:bChange  :='oCbte:oCta:SetText("Cuenta: "+oGrid:CEG_DESCRI)'

  oGrid:oSayOpc  :=oCbte:oCta
  oGrid:cRegistro:="Asiento Contable"
  oGrid:cPostSave:="GRIDPOSTSAVE"
  oGrid:cLoad    :="GRIDLOAD"
  oGrid:cTotal   :="GRIDTOTAL" 
  oGrid:cPreSave :="GRIDPRESAVE"
  oGrid:cItem    :="ASP_ITEM"
  oGrid:oFontH   :=oFontB // Fuente para los Encabezados
  oGrid:lTotal   :=.T.
  oGrid:nHeaderLines:=2
  oGrid:SetMemo("ASP_NUMMEM","Descripción Amplia",1,1,100,200)


  oGrid:nClrPane1:=oDp:nClrPane1
  oGrid:nClrPane2:=oDp:nClrPane2 
  oGrid:nClrPaneH:=14680021
  oGrid:nClrTextH:=CLR_GREEN

  oGrid:nClrPaneF:=oGrid:nClrPaneH
  oGrid:nClrTextF:=oGrid:nClrTextH
  oGrid:nRecSelColor:=oGrid:nClrPaneH
  oGrid:nClrText :=0

  oGrid:nClrTextH   :=oDp:nGrid_ClrTextH
  oGrid:nClrPaneH   :=oDp:nGrid_ClrPaneH
  oGrid:nRecSelColor:=oDp:nLbxClrHeaderPane // 12578047 // 16763283


  oGrid:nClrPaneF:=oGrid:nClrPaneH
  oGrid:nClrTextF:=oGrid:nClrTextH
  oGrid:nRecSelColor:=oGrid:nClrPaneH

  // oGrid:SetColorHead(CLR_BLUE,CLR_RED)

  // Cuenta Contable
  oCol:=oGrid:AddCol("ASP_CODCTA")
  oCol:cTitle   :="Código"+CRLF+"Partida"
  oCol:bValid   :={||oGrid:VASP_CODCTA(oGrid:ASP_CODCTA)}
  oCol:cMsgValid:="Cuenta no Existe"
  oCol:nWidth   :=130+IIF(Empty(oDp:cModeVideo),0,40)
  oCol:cListBox :="DPCTAPRESUP.BRW"
  oCol:cListBox :="DPCTAPRESUP.LBX"
  oCol:bPostEdit:='oGrid:ColCalc("ASP_MONTO")'    // Obtiene el Nombre del Producto
  oCol:nEditType:=EDIT_GET_BUTTON
  oCol:lPrimary :=.F.

  oCol:=oGrid:AddCol("CPP_DESCRI")
  oCol:cTitle   :="Descripción"+CRLF+"Partida"
  oCol:bWhen    :=".F."
  oCol:bCalc    :={||SQLGET("DPCTAPRESUP","CPP_DESCRI","CPP_CTAMOD"+GetWhere("=",oGrid:ASP_CTAMOD)+" AND CPP_CODIGO"+GetWhere("=",oGrid:ASP_CODCTA))}
  oCol:bRunOff  :={||EJECUTAR("DPCTAPRESUPCON",NIL,oGrid:ASP_CODCTA)}



  // Tipo Asiento
  oCol:=oGrid:AddCol("ASP_TIPO")
  oCol:cTitle :="Tipo"
  oCol:bValid :={||oGrid:VASP_TIPO(oGrid:ASP_TIPO)}
  oCol:bWhen  :="!Empty(oGrid:ASP_CODCTA)"
  oCol:nWidth :=35+IIF(Empty(oDp:cModeVideo),0,30)
  oCol:lRepeat:=.T.

  // Tipo
  oCol:=oGrid:AddCol("ASP_TIPDOC")
  oCol:cTitle :="Doc"
  oCol:bWhen  :="!Empty(oGrid:ASP_CODCTA)"
  oCol:nWidth :=30+IIF(Empty(oDp:cModeVideo),0,30)
  oCol:lRepeat:=.T.


  // Documento Asociado
  oCol:=oGrid:AddCol("ASP_DOCUME")
  oCol:cTitle:="Doc/Asoc"
  oCol:bWhen :="!Empty(oGrid:ASP_CODCTA)"
  oCol:nWidth:=80+IIF(Empty(oDp:cModeVideo),0,40)
  oCol:lRepeat:=.T.

  // Descripción
  oCol:=oGrid:AddCol("ASP_DESCRI")
  oCol:cTitle:="Descripción"
  oCol:bWhen :="!Empty(oGrid:ASP_CODCTA)"
  oCol:nWidth:=285+IIF(Empty(oDp:cModeVideo),0,80)

  // Monto
  oCol:=oGrid:AddCol("ASP_MONTO")
  oCol:cTitle :="Monto"
  oCol:bWhen  :="!Empty(oGrid:ASP_CODCTA)"
  oCol:cPicture:="999,999,999,999,999.99"
  oCol:nWidth :=155+IIF(Empty(oDp:cModeVideo),0,10)

  oCol:lTotal :=.T. // Genera Totales oCol:nTotal

  oCbte:oFocus    :=oCbte:oCPC_NUMERO
  oCbte:oFocusFind:=oCbte:oCPC_NUMERO
  
  oCbte:Activate()

RETURN .T.

/*
// Carga los Datos
*/
FUNCTION LOAD()

   IF oCbte:nOption=1

      oCbte:CPC_FECHA  :=oDp:dFecha
      oCbte:CPC_TIPO   :=oCbte:cTipo
      oCbte:CPC_NUMERO :=SQLINCREMENTAL("DPCBTEPRESUP","CPC_NUMERO","CPC_CODSUC"+GetWhere("=",oDp:cSucursal   ))
      oCbte:lSaved     :=.F.

      oCbte:CPC_CODSUC :=oDp:cSucursal
      oCbte:oCPC_NUMERO:Refresh(.T.)
      oCbte:oCPC_FECHA :Refresh(.T.)

      oGrid:GetTotal("ASP_MONTO")
      oGrid:CancelEdit()
      oGrid:ShowTotal()
      oCbte:oFocus:=oCbte:oCPC_NUMERO
      DPFOCUS(oCbte:oCPC_NUMERO)

   ENDIF

//   oGrid:ShowTotal()

   IF oCbte:nOption=0
//      oGrid:CancelEdit()
      oCbte:dFecha   :=oCbte:CPC_FECHA
      oCbte:cNumero  :=oCbte:CPC_NUMERO
   ELSE
      DpFocus(oCbte:oCPC_NUMERO)
   ENDIF

   IF oCbte:nOption=3 .AND. !EJECUTAR("DPVALDOCPRE",oCbte,"PRE")
      Return .F.
   ENDIF

   COMBOINI(oCbte:oCPC_TIPO)

   // Calcula todos los Totales
   // oCbte:aGrids[1]:PostSave()

RETURN .T.

/*
// Ejecuta la Impresión del Documento
*/
FUNCTION PRINTER()
   LOCAL cRep:="ASIENTOACT",oRep

   IF oCbte:CPC_ACTUAL="N"
      cRep:="ASIENTODIF"
   ENDIF
   
   IF oCbte:CPC_ACTUAL="A"
      cRep:="ASIENTOAUD"
   ENDIF

   oRep:=REPORTE(cRep)
   oRep:SetRango(1,oCbte:CPC_NUMERO,oCbte:CPC_NUMERO)
   oRep:SetRango(2,oCbte:CPC_FECHA ,oCbte:CPC_FECHA )

RETURN .T.

FUNCTION PRESAVE()

  IF !oCbte:CBTFECHA()
     RETURN .F.
  ENDIF

  IF !oCbte:lSaved
     RETURN .T.
  ENDIF

  oCbte:CPC_TIPO:=oCbte:aTipos[oCbte:oCPC_TIPO:nAt]

  oCbte:GRIDTOTAL() // Calcula el Total  cScope:="ASP_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND ASP_ACTUAL"+GetWhere("=",cTipo)

RETURN .T.

/*
// Permiso para Borrar
*/
FUNCTION PREDELETE()

  // Validar que el comprobante no este en ningun documento tanto en DPDOCPRO como
  //         DPDOCCLI. 
  IF !EJECUTAR("DPVALDOCPRE",oCbte,"PRE")
     RETURN .F.
  ENDIF 

  IF !MsgNoYes("Desea Borrar el Comprobante: "+oCbte:CPC_NUMERO+;
                CRLF+"Fecha: "+DTOC(oCbte:CPC_FECHA),"Eliminar Registro")

     RETURN .F.

  ENDIF

RETURN .T.

/*
// Después de Borrar
*/
FUNCTION POSTDELETE()

 // no hay mas Comprobante
 IF COUNT("DPCBTEPRESUP",oCbte:cScope)=0
   oCbte:LoadData(1)
 ENDIF

RETURN .T.

FUNCTION VASP_TIPO(cTipo)
   LOCAL lresp:=.f.,I
   FOR I=1 to Len(oCbte:aTipos)
      IF oCbte:aTipos[I]=cTipo
         Return .t.
      ENDIF
   NEXT I
   MensajeErr("Tipo de Asiento no Existe")
RETURN lresp

FUNCTION VASP_CODCTA(cCodCta)
  LOCAL cTipo

  IF EMPTY(oGrid:ASP_CODCTA)
     RETURN .F.
  ENDIF

  oGrid:SET("ASP_TIPO"  ,LEFT(oCbte:CPC_TIPO,2),.T.  )
  oGrid:SET("CPP_DESCRI",SQLGET("DPCTAPRESUP","CPP_DESCRI,CPP_TIPO","CPP_CTAMOD"+GetWhere("=",oGrid:ASP_CTAMOD)+" AND CPP_CODIGO"+GetWhere("=",oGrid:ASP_CODCTA)),.T.)

  cTipo:=oDp:aRow[2]

  IF cTipo="T"
     oGrid:MensajeErr("Cuenta Totalizadora","Utilice cuentas para Detalles")
     RETURN .T.
  ENDIF
 
RETURN .T.

/*
// Carga para Incluir o Modificar en el Grid
*/
FUNCTION GRIDLOAD()
   LOCAL nTotal:=0

   IF oGrid:nOption=1

     oGrid:Set("ASP_CODSUC",oDp:cSucursal)
     oGrid:Set("ASP_TIPO"  ,oCbte:cTipo)
     oGrid:Set("ASP_CTAMOD",oDp:cCtaMod)

     nTotal:=oGrid:GetTotal("ASP_MONTO")
     nTotal:=nTotal*IIF(nTotal=0,1,-1)
     oGrid:Set("ASP_MONTO",nTotal,.T.)
   ENDIF

RETURN NIL

/*
// Ejecución despues de Grabar el Item
*/
FUNCTION GRIDPOSTSAVE()
/*
  IF COUNT("DPPLACOS","PLA_CODCTA"+GetWhere("=",oGrid:ASP_CUENTA))>0

     EJECUTAR("DPCENCOSDIST",oGrid:ASP_CODSUC ,;
                             oGrid:ASP_ACTUAL ,;
                             oGrid:ASP_FECHA  ,;
                             oGrid:ASP_NUMERO ,;
                             oGrid:ASP_ITEM   ,;
                             oGrid:ASP_CUENTA,;
                             oGrid:ASP_MONTO)

  ENDIF
*/
RETURN .T.

/*
// Genera los Totales por Grid
*/
FUNCTION GRIDTOTAL()

// LOCAL nDebe:=0,nHaber:=0
// LOCAL oCol:=oGrid:GetCol("ASP_MONTO")
// oCbte:nDebe :=oCol:CalCuleRow("IIF(oGrid:ASP_MONTO>0,oGrid:ASP_MONTO,0)")
// oCbte:nHaber:=oCol:CalCuleRow("IIF(oGrid:ASP_MONTO<0,oGrid:ASP_MONTO,0)")*-1
// oCbte:nTotal:=oCbte:nDebe-oCbte:nHaber
// oCbte:oDebe :Refresh(.T.)
// oCbte:oHaber:Refresh(.T.)

RETURN .F.

FUNCTION CBTFECHA()
  LOCAL lResp:=.T.

//  lResp:=EJECUTAR("VALFCHEJER",oCbte:CPC_FECHA,"Comprobante Contable") .AND.;
//        oCbte:ValUnique(NIL,NIL,NIL,"Comprobante Contable ya Existe")

RETURN lResp

FUNCTION GRIDPRESAVE()
    LOCAL cWhere

    IF Empty(oCbte:CPC_CENCOS) .OR. !ISSQLGET("DPCENCOS","CEN_CODIGO",oCbte:CPC_CENCOS)
       MensajeErr("Requiere "+GetFromVar("{oDp:DPCENCOS}"))
       DPFOCUS(oCbte:oCPC_CENCOS)
       RETURN .F.
    ENDIF

    IF !oCbte:CBTFECHA()
        RETURN .F.
    ENDIF

    IF oCbte:nOption=3 .AND.  ( oCbte:dFecha<>oCbte:CPC_FECHA  .OR. oCbte:cNumero<>oCbte:CPC_NUMERO)

       cWhere:="CPC_CODSUC"+GetWhere("=", oCbte:CPC_CODSUC)+" AND "+;
               "CPC_FECHA" +GetWhere("=", oCbte:dFecha    )+" AND "+;
               "CPC_NUMERO"+GetWhere("=", oCbte:cNumero   )+" AND "+;
               "CPC_TIPO  "+GetWhere("=", oCbte:cTipo   )

       SQLUPDATE("DPCBTEPRESUP" , {"CPC_FECHA","CPC_NUMERO"},{oCbte:CPC_FECHA,oCbte:CPC_NUMERO} , cWhere)

       oCbte:cWhereOpen:=oCbte:GetWhere(NIL,.T.) // Necesario para Validar VALUNIQUE()

    ENDIF

    oCbte:dFecha :=oCbte:CPC_FECHA 
    oCbte:cNumero:=oCbte:CPC_NUMERO

RETURN .T.

/*
// Validar Centro de Costos
*/
FUNCTION VALCENCOS()

   IF Empty(oCbte:CPC_CENCOS) .OR. !ISSQLGET("DPCENCOS","CEN_CODIGO",oCbte:CPC_CENCOS)
      oCbte:oCPC_CENCOS:KeyBoard(VK_F6)
      RETURN .T.
   ENDIF

   oCbte:oCENCOS:Refresh(.T.)

RETURN .T.
// EOF


