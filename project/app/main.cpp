#include "app.h"
#include <iostream>

using namespace std;

void main()
{
	cout << "<--------------------Fractal   Cloud-------------------------->\n" << endl;
	cout << "                   Projektarbeit GDV 2" << endl;
	cout << "                      Felix Zwicker" << endl;
	cout << "<------------------------------------------------------------->\n";

    CApplication Application;

    RunApplication(800, 600, "Cloud Fractal", &Application);
}