#include <TFile.h>
#include <TTree.h>
#include <TChain.h>
#include <TF1.h>
#include <TDatabasePDG.h>
#include <TParticlePDG.h>

struct event {
    double weight=0;
    double lepOut_E=0;
    double lepOut_Px=0;
    double lepOut_Py=0;
    double lepOut_Pz=0;
    double lepIn_E=0;
    int nucleus_A=0;
    int nucleus_Z=0;        
    int    evType=0;
    std::vector<double> *px=0;
    std::vector<double> *py=0;
    std::vector<double> *pz=0;
    std::vector<double> *e=0;
    std::vector<int> *barcode=0;
    std::vector<int> *pid=0;
};

void gibuu2lund(int nevents) {

    FILE *output = fopen("gibuu.dat", "w");

    if (!output) {
        fprintf(stderr, "ERROR: Could not open gibuu.dat for writing\n");
        exit(1);
    }

    struct event t;

    TChain *tree = new TChain("RootTuple");
    tree->Add("EventOutput.Pert.00000001.root");

    tree->SetBranchAddress("barcode", &t.pid);
    tree->SetBranchAddress("Px", &t.px);
    tree->SetBranchAddress("Py", &t.py);
    tree->SetBranchAddress("Pz", &t.pz);
    tree->SetBranchAddress("E", &t.e);
    tree->SetBranchAddress("weight", &t.weight);
    tree->SetBranchAddress("lepIn_E", &t.lepIn_E);
    tree->SetBranchAddress("nucleus_A", &t.nucleus_A);
    tree->SetBranchAddress("nucleus_Z", &t.nucleus_Z);    
    tree->SetBranchAddress("lepOut_E",  &t.lepOut_E);
    tree->SetBranchAddress("lepOut_Px", &t.lepOut_Px);
    tree->SetBranchAddress("lepOut_Py", &t.lepOut_Py);
    tree->SetBranchAddress("lepOut_Pz", &t.lepOut_Pz);
    tree->SetBranchAddress("evType", &t.evType);

    const float vx=0;
    const float vy=0;
    const float vz=0;

    for (int ievent = 0; ievent < tree->GetEntries(); ++ievent) {

        if (nevents > 0 && ievent >= nevents) break;

        tree->GetEvent(ievent);

        // The event header:
        fprintf(output, "%lu ", t.px->size()+1);
        fprintf(output, "%i ", t.nucleus_A);
        fprintf(output, "%i ", t.nucleus_Z);        
        fprintf(output, "%i ", 0);
        fprintf(output, "%i ", 0);
        fprintf(output, "%.4e ", 0.00051184);
        fprintf(output, "%.4e ", t.lepIn_E);        
        fprintf(output, "%.4e ", 2212.0);
        fprintf(output, "%i ", t.evType);
        fprintf(output, "%.4e ", t.weight);
        fprintf(output, "\n");

        // The scattered lepton:
        // Use the four-momentum written directly by GiBUU 2025.
        const double px = t.lepOut_Px;
        const double py = t.lepOut_Py;
        const double pz = t.lepOut_Pz;
        const double e  = t.lepOut_E;

        fprintf(output, "%s ", "");
        fprintf(output, "%i ", 1);
        fprintf(output, "%i ", -1);
        fprintf(output, "%i ", 1);
        fprintf(output, "%i ", 11);
        fprintf(output, "%i ", 0);
        fprintf(output, "%i ", 0);
        fprintf(output, "%.4e ", px);
        fprintf(output, "%.4e ", py);
        fprintf(output, "%.4e ", pz);
        fprintf(output, "%.4e ", e);
        fprintf(output, "%.4e ", 0.00051184);
        fprintf(output, "%.4e ", vx);
        fprintf(output, "%.4e ", vy);
        fprintf(output, "%.4e ", vz);
        fprintf(output, "\n");

        // The other final-state particles:
        for (int ipart = 0; ipart < t.pid->size(); ipart++) {

            TParticlePDG *p =
                TDatabasePDG::Instance()->GetParticle(t.pid->at(ipart));
            fprintf(output, "%s ", "");
            fprintf(output, "%i ", ipart + 2);
            fprintf(output, "%i ", int(p->Charge()/3));
            fprintf(output, "%i ", 1);
            fprintf(output, "%i ", t.pid->at(ipart));
            fprintf(output, "%i ", 0);
            fprintf(output, "%i ", 0);
            fprintf(output, "%.4e ", t.px->at(ipart));
            fprintf(output, "%.4e ", t.py->at(ipart));
            fprintf(output, "%.4e ", t.pz->at(ipart));
            fprintf(output, "%.4e ", t.e->at(ipart));
            fprintf(output, "%.4e ", p->Mass());
            fprintf(output, "%.4e ", vx);
            fprintf(output, "%.4e ", vy);
            fprintf(output, "%.4e ", vz);
            fprintf(output, "\n");
        }
    }

    fclose(output);
    delete tree;
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        printf("Usage: gibuu2lund #EVENTS\n");
        exit(1);
    }

    gibuu2lund(atoi(argv[1]));

    return 0;
}
