// Programa   : DPCTAPRESUP
// Fecha/Hora : 06/05/2006 13:09:34
// Propósito  : Incluir/Modificar DPCTAPRESUP
// Creado Por : DpXbase
// Llamado por: DPCTAPRESUP.LBX
// Aplicación : Contabilidad                            
// Tabla      : DPCTAPRESUP

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION DPCTAPRESUP(nOption,cCodigo)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cTitle,cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL cTitle:="Cuentas de Presupuesto"
  LOCAL aItems1:=GETOPTIONS("DPCTAPRESUP","CPP_CLASIF")

  IF Empty(aItems1)
     aItems1:={}
     AADD(aItems1,"Indefinida")
  ENDIF


  cExcluye:="CPP_CODIGO,;
             CPP_DESCRI,;
             CPP_CODCTA"

  DEFAULT cCodigo:="1234"

  DEFAULT nOption:=1

   nOption:=IIF(nOption=2,0,nOption) 

  DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Tahoma" SIZE 0, -11

  nClrText:=10485760 // Color del texto

  IF nOption=1 // Incluir
    cSql     :=[SELECT * FROM DPCTAPRESUP WHERE ]+BuildConcat("CPP_CODIGO")+GetWhere("=",cCodigo)+[]
    cTitle   :=" Incluir {oDp:DPCTAPRESUP}"
  ELSE // Modificar o Consultar
    cSql     :=[SELECT * FROM DPCTAPRESUP WHERE ]+BuildConcat("CPP_CODIGO")+GetWhere("=",cCodigo)+[]
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" Cuentas de Presupuesto                  "
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" {oDp:DPCTAPRESUP}"
  ENDIF

  oTable:=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)

 // oTable:Browse()

  oCTABANCO:BCO_CUENTA:=EJECUTAR("DPGETCTAMOD","DPCTAPRESUP_CTA",oCTAPRESUP:CPP_CODIGO,NIL,"CUENTA")

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM DPCTAPRESUP]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="CPP_CODIGO" // Clave de Validación de Registro

  oCTAPRESUP:=DPEDIT():New(cTitle,"DPCTAPRESUP.edt","oCTAPRESUP" , .F. )

  oCTAPRESUP:nOption  :=nOption
  oCTAPRESUP:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oCTAPRESUP
  oCTAPRESUP:SetScript()        // Asigna Funciones DpXbase como Metodos de oCTAPRESUP
  oCTAPRESUP:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oCTAPRESUP:nClrPane:=oDp:nGris

  IF oCTAPRESUP:nOption=1 // Incluir en caso de ser Incremental
     // oCTAPRESUP:RepeatGet(NIL,"CPP_CODIGO") // Repetir Valores


     oCTAPRESUP:CPP_ACTIVO:=.T.
     
     // AutoIncremental 
  ENDIF
  //Tablas Relacionadas con los Controles del Formulario

  oCTAPRESUP:CPP_CODCTA:=EJECUTAR("DPGETCTAMOD","DPCTAPRESUP_CTA",oCTAPRESUP:CPP_CODIGO,NIL,"CUENTA")

  oCTAPRESUP:CreateWindow()       // Presenta la Ventana
  
  oCTAPRESUP:ViewTable("DPCTA","CTA_DESCRI","CTA_CODIGO","CPP_CODCTA")
  
  //
  // Campo : CPP_CODIGO
  // Uso   : Código                                  
  //
  @ 1.0, 1.0 GET oCTAPRESUP:oCPP_CODIGO  VAR oCTAPRESUP:CPP_CODIGO  VALID oCTAPRESUP:ValUnique(oCTAPRESUP:CPP_CODIGO);
                   .AND. !VACIO(oCTAPRESUP:CPP_CODIGO,NIL);
                    WHEN (AccessField("DPCTAPRESUP","CPP_CODIGO",oCTAPRESUP:nOption);
                    .AND. oCTAPRESUP:nOption!=0);
                    FONT oFontG;
                    SIZE 80,10

    oCTAPRESUP:oCPP_CODIGO:cMsg    :="Código"
    oCTAPRESUP:oCPP_CODIGO:cToolTip:="Código"

    @ oCTAPRESUP:oCPP_CODIGO:nTop-08,oCTAPRESUP:oCPP_CODIGO:nLeft SAY "Código" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


    @ 2.8, 10 CHECKBOX oCTAPRESUP:oCPP_ACTIVO  VAR oCTAPRESUP:CPP_ACTIVO  PROMPT ANSITOOEM("Activo");
                        WHEN (AccessField("DPCTAPRESUP","CPP_ACTIVO",oCTAPRESUP:nOption);
                       .AND. oCTAPRESUP:nOption!=0 .AND. DPVERSION()>4);
                        FONT oFont COLOR nClrText,NIL SIZE 166,10;
                        SIZE 4,10

 
    oCTAPRESUP:oCPP_ACTIVO:cMsg    :="Activo"
    oCTAPRESUP:oCPP_ACTIVO:cToolTip:="Activo"

  //
  // Campo : CPP_DESCRI
  // Uso   : Descripción                             
  //
  @ 2.8, 1.0 GET oCTAPRESUP:oCPP_DESCRI  VAR oCTAPRESUP:CPP_DESCRI  VALID  !VACIO(oCTAPRESUP:CPP_DESCRI,NIL);
                    WHEN (AccessField("DPCTAPRESUP","CPP_DESCRI",oCTAPRESUP:nOption);
                    .AND. oCTAPRESUP:nOption!=0);
                    FONT oFontG;
                    SIZE 160,10

    oCTAPRESUP:oCPP_DESCRI:cMsg    :="Descripción"
    oCTAPRESUP:oCPP_DESCRI:cToolTip:="Descripción"

  @ oCTAPRESUP:oCPP_DESCRI:nTop-08,oCTAPRESUP:oCPP_DESCRI:nLeft SAY "Descripción" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : CPP_CODCTA
  // Uso   : Cuenta Contable Equivalente             
  //
  @ 4.6, 1.0 BMPGET oCTAPRESUP:oCPP_CODCTA  VAR oCTAPRESUP:CPP_CODCTA ;
                VALID oCTAPRESUP:oDPCTA:SeekTable("CTA_CODIGO",oCTAPRESUP:oCPP_CODCTA,NIL,oCTAPRESUP:oCTA_DESCRI);
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("DPCTA",NIL,"CTA_ACTIVO=1",NIL,NIL,NIL,NIL,NIL,NIL,oCTAPRESUP:oCPP_CODCTA,NIL), oDpLbx:GetValue("CTA_CODIGO",oCTAPRESUP:oCPP_CODCTA)); 
                    WHEN (AccessField("DPCTAPRESUP","CPP_CODCTA",oCTAPRESUP:nOption);
                    .AND. oCTAPRESUP:nOption!=0);
                    FONT oFontG;
                    SIZE 80,10

    oCTAPRESUP:oCPP_CODCTA:cMsg    :="Cuenta Contable Equivalente"
    oCTAPRESUP:oCPP_CODCTA:cToolTip:="Cuenta Contable Equivalente"

  @ oCTAPRESUP:oCPP_CODCTA:nTop-08,oCTAPRESUP:oCPP_CODCTA:nLeft SAY GetFromVar("{oDp:xDPCTA}") PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

//GetFromVar("{oDp:xDPCTA}")
  @ oCTAPRESUP:oCPP_CODCTA:nTop,oCTAPRESUP:oCPP_CODCTA:nRight+5 SAY oCTAPRESUP:oCTA_DESCRI;
                            PROMPT oCTAPRESUP:oDPCTA:CTA_DESCRI PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680 


/*
// Partida Presupuestaria
*/
  @ 5.4,15.0 COMBOBOX oCTAPRESUP:oCPP_CLASIFI VAR oCTAPRESUP:CPP_CLASIFI ITEMS aItems1;
                      WHEN (AccessField("DPCTAPRESUP","CPP_CLASIFI",oCTAPRESUP:nOption);
                    .AND. oCTAPRESUP:nOption!=0);
                      FONT oFontG;


   ComboIni(oCTAPRESUP:oCTAPRESUP_TIPREP)


    oCTAPRESUP:oCPP_CLASIFI:cMsg    :="Partida Presupuestaria"
    oCTAPRESUP:oCPP_CLASIFI:cToolTip:="Partida Presupuestaria"

  @ oCTAPRESUP:oCTAPRESUP_TIPREP:nTop-08,oCTAPRESUP:oCTAPRESUP_TIPREP:nLeft SAY "Partida Presupuestaria" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

/*

  IF nOption!=2

    @09, 33  SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\XSAVE.BMP" NOBORDER;
             LEFT PROMPT "Grabar";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oCTAPRESUP:Save())

    oBtn:cToolTip:="Grabar Registro"
    oBtn:cMsg    :=oBtn:cToolTip

    @09, 43 SBUTTON oBtn ;
            SIZE 45, 20 FONT oFont;
            FILE "BITMAPS\XCANCEL.BMP" NOBORDER;
            LEFT PROMPT "Cancelar";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION (oCTAPRESUP:Cancel()) CANCEL

    oBtn:lCancel :=.T.
    oBtn:cToolTip:="Cancelar y Cerrar Formulario "
    oBtn:cMsg    :=oBtn:cToolTip

  ELSE


     @09, 43 SBUTTON oBtn ;
             SIZE 42, 23 FONT oFontB;
             FILE "BITMAPS\XSALIR.BMP" NOBORDER;
             LEFT PROMPT "Salir";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oCTAPRESUP:Cancel()) CANCEL

             oBtn:lCancel:=.T.
             oBtn:cToolTip:="Cerrar Formulario"
             oBtn:cMsg    :=oBtn:cToolTip

  ENDIF

*/

  oCTAPRESUP:Activate({||oCTAPRESUP:INICIO()})

  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oCTAPRESUP


FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oCTAPRESUP:oDlg
   LOCAL nLin:=0

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -14 BOLD


   IF oCTAPRESUP:nOption!=2

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
            ACTION (oCTAPRESUP:Save())

     oBtn:cToolTip:="Guardar"

     oCTAPRESUP:oBtnSave:=oBtn


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XCANCEL.BMP";
            ACTION (oCTAPRESUP:Cancel()) CANCEL


   
   ELSE


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSALIR.BMP";
            ACTION (oCTAPRESUP:Cancel()) CANCEL

   ENDIF

   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })


 
RETURN .T.




/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oCTAPRESUP:nOption=1 // Incluir en caso de ser Incremental
     
     // AutoIncremental 
  ENDIF

RETURN .T.
/*
// Ejecuta Cancelar
*/
FUNCTION CANCEL()
RETURN .T.

/*
// Ejecución PreGrabar
*/
FUNCTION PRESAVE()
  LOCAL lResp:=.T.

// ? oCTAPRESUP:CPP_CODCTA
// oCTAPRESUP:CPP_CODCTA:=EJECUTAR("DPGETCTAMOD","DPCTAPRESUP_CTA",oCTAPRESUP:oCPP_CODIGO,NIL,"CUENTA")
//  EJECUTAR("SETCTAINTMOD","DPCTAPRESUP_CTA",oCTAPRESUP:CPP_CODIGO,"","CUENTA",oCAJA:CAJ_CODIGO,.T.)

  IF !ISSQLFIND("DPCTA","CTA_CODIGO"+GetWhere("=",oCTAPRESUP:CPP_CODCTA)) 
     EVAL(oCTAPRESUP:oCPP_CODCTA:bAction)
     RETURN .F.
  ENDIF

  EJECUTAR("SETCTAINTMOD","DPCTAPRESUP_CTA",oCTAPRESUP:CPP_CODIGO,"","CUENTA",oCTAPRESUP:CPP_CODCTA,.T.)


  lResp:=oCTAPRESUP:ValUnique(oCTAPRESUP:CPP_CODIGO)

  IF !lResp
    MsgAlert("Registro "+CTOO(oCTAPRESUP:CPP_CODIGO),"Ya Existe")
  ENDIF

RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()
RETURN .T.

/*
<LISTA:CPP_CODIGO:Y:GET:N:N:N:Código,CPP_DESCRI:N:GET:N:N:N:Descripción,CPP_CODCTA:N:BMPGETL:N:N:Y:Cuenta Contable Equivalente>
*/
