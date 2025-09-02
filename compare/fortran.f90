module mandelbrot_mod
    use iso_c_binding
    implicit none
    ! Definition der Result-Struktur
    type, bind(c) :: result
        real(c_double) :: c
        real(c_double) :: ci
        integer(c_int) :: i
    end type result
contains
    ! Mandelbrot-Iteration für einen Punkt
    subroutine mandel(x, y, max_iter, r) bind(c, name="mandel")
        real(c_double), value :: x, y
        integer(c_int), value :: max_iter
        type(result), intent(out) :: r
        real(c_double) :: c, ci, c2, ci2
        integer(c_int) :: i

        c = 0.0_c_double
        ci = 0.0_c_double
        c2 = 0.0_c_double
        ci2 = 0.0_c_double
        i = 0
        do while ((c2 + ci2 < 4.0_c_double) .and. (i < max_iter))
            ci = (c * ci * 2.0_c_double) + y
            c = (c2 - ci2) + x
            c2 = c * c
            ci2 = ci * ci
            i = i + 1
        end do
        ! Ergebnisse speichern
        r%c = c
        r%ci = ci
        r%i = i
    end subroutine mandel

    ! Benchmark-Funktion
    subroutine benchmark(n, r) bind(c, name="benchmark")
        integer(c_int), value :: n
        type(result), intent(out) :: r
        integer(c_int) :: i
        ! Direkter Aufruf von mandel (kein malloc nötig, r ist bereits allokiert)
        do i = 1, n
            call mandel(0.1_c_double, -0.5_c_double, 5000, r)
        end do
    end subroutine benchmark
end module mandelbrot_mod

! Hauptprogramm zum Testen
program mandelbrot
    use mandelbrot_mod
    implicit none
    type(result) :: r
    ! Benchmark aufrufen
    call benchmark(50000, r)
    ! Ergebnis ausgeben, um Optimierung zu verhindern
    print *, "Result: c=", r%c, "ci=", r%ci, "i=", r%i
end program mandelbrot
