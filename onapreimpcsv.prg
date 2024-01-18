// Programa   : ONAPREIMPCSV
// Fecha/Hora : 19/11/2019 21:39:22
// Propósito  : Importar Partidas Presupuestarias ONAPRE, desde excel guardar como CSV en carpeta c:\dpsgev60\ejemplo
//              luego, desde ejecutar comando: EJECUTAR("ONAPREIMPCSV")
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cFile,lReset)
  LOCAL aData,I
  LOCAL oTable,cCodigo,cCodNiv,lCtaDet

  DEFAULT cFile :="EJEMPLO\ONAPRE.CSV",;
          lReset:=.T.

  IF !FILE(cFile)
     RETURN .F.
  ENDIF

  IF lReset
    SQLDELETE("DPCTAPRESUP")
  ENDIF

//  ? FILE(cFile)
  aData:=MEMOREAD(cFile)
  aData:=STRTRAN(aData,CRLF,CHR(10))

  aData:=_VECTOR(aData,CHR(10))

  AEVAL(aData,{|a,n| aData[n]:=_VECTOR(a,";")})

  ADEPURA(aData,{|a,n| !ISDIGIT(LEFT(a[1],1))})

  oTable:=OpenTable("SELECT * FROM DPCTAPRESUP",.F.)
  //oTable:=INSERTINTO("DPCTAPRESUP")
  oTable:lAuditar:=.F.
  oTable:SetForeignkeyOff()

  FOR I=1 TO LEN(aData)

    cCodigo:=ALLTRIM(aData[I,1]) // 4-01-01-01-00-001
    lCtaDet:=LEN(cCodigo)=16
    cCodigo:=LEFT(cCodigo,1  )+"-"+;
             SUBS(cCodigo,2,2)+"-"+;
             SUBS(cCodigo,4,2)+"-"+;
             SUBS(cCodigo,6,2)+"-"+;
             SUBS(cCodigo,8,2)+"-"+;
             RIGHT(cCodigo,3)

   
    cCodNiv:=ALLTRIM(cCodigo) // 4-01-01-01-00-001
    cCodigo:=STRTRAN(cCodigo,"-00-00-00-00-000","")
    cCodigo:=STRTRAN(cCodigo,"-00-00-00-000"   ,"")
    cCodigo:=STRTRAN(cCodigo,"-00-00-000"      ,"")
//  cCodigo:=STRTRAN(cCodigo,"-00-000"         ,"")
    cCodigo:=STRTRAN(cCodigo,"-000"            ,"")

    cCodigo:=ALLTRIM(cCodigo)
    IF RIGHT(cCodigo,3)="-00"
       cCodigo:=LEFT(cCodigo,LEN(cCodigo)-3)
    ENDIF

    cCodNiv:=cCodigo
    oTable:AppendBlank()
    oTable:Replace("CPP_CODIGO",cCodigo)  // aData[I,1])
    oTable:Replace("CPP_CODCTA",aData[I,6])
    oTable:Replace("CPP_DESCRI",aData[I,2])
    oTable:Replace("CPP_NIVEL" ,aData[I,3])
    oTable:Replace("CPP_TIPO"  ,aData[I,4])
    oTable:Replace("CPP_CODNIV",cCodNiv )
    oTable:Replace("CPP_CTAMOD",oDp:cCtaMod)
    oTable:Replace("CPP_ACTIVO",.T.       )
    oTable:Replace("CPP_CTADET",lCtaDet   )

    oTable:Commit()

  NEXT I

  oTable:End()


//ViewArray(aData)
  
RETURN NIL

/*
 C001=CPP_CODCTA          ,'C',020,0,'','Cuenta Contable',0
 C002=CPP_CODIGO          ,'C',020,0,'PRIMARY KEY NOT NULL','C¾digo',0
 C003=CPP_DESCRI          ,'C',040,0,'','Descripci¾n',0
 C004=CPP_ITEM            ,'C',005,0,'','Item',1
 C005=CPP_NIVEL           ,'N',002,0,'','Nivel',0
 C006=CPP_NUMMEM          ,'N',008,0,'','N·mero de Memo',0
 C007=CPP_PUBLI           ,'C',001,0,'','Publicaci¾n',0
 C008=CPP_TIPO            ,'C',001,0,'','Tipo',0
*/
// EOF
