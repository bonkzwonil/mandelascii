        IDENTIFICATION DIVISION.
        PROGRAM-ID. HALLOPGM.
        DATA DIVISION.
        WORKING-STORAGE SECTION.
        77  C   PIC SV9(07) COMP.
        77  CI  PIC SV9(07) COMP.
        77  C2  PIC V9(07) COMP.
        77  CI2 PIC V9(07) COMP.
        77  ZWI PIC V9(07) COMP.
        77  I   PIC 9(7)   COMP.
        77  BI   PIC 9(8)   COMP.
        77  X   PIC SV9(07)   COMP.
        77  Y   PIC SV9(07)   COMP.
        77  MAXI PIC 9(5) VALUE 5000.
        PROCEDURE DIVISION.
        P-START.
            DISPLAY "LOOK MA! COBOL!"
            MOVE 0.1 TO X
            MOVE -0.5 TO Y
            PERFORM P-MANDEL
            EXHIBIT NAMED C CI I
            PERFORM P-BENCHMARK
            EXHIBIT NAMED C CI I BI
            PERFORM P-END.
        P-MANDEL.
            MOVE 0 TO ZWI C,CI,CI2,C2
            PERFORM P-ITER VARYING I FROM 1 BY 1
                UNTIL ZWI > 4 OR I >= MAXI.
        P-ITER.
            MULTIPLY C BY CI
            MULTIPLY 2 BY CI
            ADD Y TO CI
            SUBTRACT CI2 FROM C2 GIVING C
            ADD X TO C
            MULTIPLY C BY C GIVING C2
            MULTIPLY CI BY CI GIVING CI2
            ADD C2 TO CI2 GIVING ZWI.
        P-BENCHMARK.
            PERFORM P-MANDEL VARYING BI FROM 1 BY 1
                    UNTIL BI GREATER THAN 1000.
        P-END.
            DISPLAY "The ENd"
            STOP RUN.
