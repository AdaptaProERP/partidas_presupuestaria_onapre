// Programa   : DPCTAPRESUPMENUBAR
// Fecha/Hora : 03/08/2023 04:33:54
// Propósito  : Agrega Controles en la Barra de Botones
// Creado Por : Juan Navas
// Llamado por: DPLBX("DPCTAMENU.LBX")
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oLbx)
  LOCAL aCtaBg:={"4-01","4-02","4-03","4-04","4-05","4-06","4-07","4-08"}
//oDp:cCtaBg1,oDp:cCtaBg2,oDp:cCtaBg3,oDp:cCtaBg4,;
//                oDp:cCtaGp1,oDp:cCtaGp2,oDp:cCtaGp3,oDp:cCtaGp4,oDp:cCtaGp5,oDp:cCtaGp6}
  LOCAL I,oBtn,oFont,cAction
  LOCAL nLastKey:=13,oCol,nContar:=0

  aCtaBg:=ATABLE("SELECT CPP_CODIGO FROM DPCTAPRESUP WHERE LENGTH(CPP_CODIGO)=4")

  EJECUTAR("GETCTAUTIL")

  IF Empty(oDp:cCtaUti)
    ADEPURA(aCtaBg,{|a,n| Empty(a) }) // .OR. ALLTRIM(a)=ALLTRIM(oDp:cCtaUti)})
  ELSE
    ADEPURA(aCtaBg,{|a,n| Empty(a) .OR. ALLTRIM(a)=ALLTRIM(oDp:cCtaUti)})
  ENDIF

  ADEPURA(cCtaBg,{|a,n| a=oDp:cCtaUti})

  IF oLbx=NIL
     RETURN .T.
  ENDIF

  DEFAULT oDp:aCtaNombrePrep:={}

  IF Empty(oDp:aCtaNombrePrep) 
     oDp:aCtaNombre:={}
     AEVAL(aCtaBg,{|a,n| AADD(oDp:aCtaNombrePrep,ALLTRIM(SQLGET("DPCTAPRESUP","CPP_DESCRI","CPP_CODIGO"+GetWhere("=",a))))})
  ENDIF

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD 

 

  FOR I=1 TO LEN(aCtaBg)

     IF ISSQLFIND("DPCTAPRESUP","LEFT(CPP_CODIGO,4)"+GetWhere("=",aCtaBg[I]))

       aCtaBg[I]:=IF(!Empty(oDp:cCtaUti) .AND. ALLTRIM(aCtaBg[I])=ALLTRIM(oDp:cCtaUti),"RE",aCtaBg[I])

       nContar++

       @ 44+18,20+(40*(nContar-1)) BUTTON oBtn PROMPT aCtaBg[I] SIZE 27+4,24;
                        FONT oFont;
                        OF oLbx:oBar;
                        PIXEL;
                        ACTION (1=1)

      oBtn:CARGO  :=oLbx // Copia del Boton
      cAction     :=[EJECUTAR("DPCTALBXFIND",]+GetWhere("",aCtaBg[I])+[)]

      oBtn:bAction:=BLOQUECOD(cAction)

      IF Empty(aCtaBg[I])

        oBtn:cToolTip:="Restaurar Todas las Cuentas"

      ELSE

        oBtn:cToolTip:=oDp:aCtaNombrePrep[I]
 
        IF Empty(oDp:aCtaNombrePrep[I])
          oBtn:bWhen:={||.F.}
          oBtn:ForWhen(.T.)
        ENDIF

      ENDIF

      IF aCtaBg[I]="RE"
        oBtn:cToolTip:="Resultado del Ejercicio "+oDp:cCtaUti
      ENDIF

    ENDIF

  NEXT I

  IF nContar>0
    oLbx:oBar:SetSize(NIL,90,.T.)
  ENDIF

RETURN .T.
// EOF


