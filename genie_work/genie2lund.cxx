#include <TFile.h>
#include <TTree.h>
#include <TChain.h>
#include <TF1.h>
#include <TDatabasePDG.h>
#include <TParticlePDG.h>

const int MAX_PARTICLES = 1000;

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
    int hitnuc=0;

    int nf = 0;
    double px[MAX_PARTICLES];
    double py[MAX_PARTICLES];
    double pz[MAX_PARTICLES];
    double e[MAX_PARTICLES];
    int pid[MAX_PARTICLES];
};

void genie2lund(int nevents) {

    FILE *output = fopen("rgm_eAr_5p98636GeV_test_lund.dat", "w");

    if (!output) {
        fprintf(stderr, "ERROR: Could not open rgm_eAr_5p98636GeV_test_lund.dat for writing\n");
        exit(1);
    }

    struct event t;

    TChain *tree = new TChain("gst");
    tree->Add("rgm_eAr_5p98636GeV.gst.root");

    tree->SetBranchAddress("nf", &t.nf);
    tree->SetBranchAddress("pdgf", t.pid);
    tree->SetBranchAddress("pxf", t.px);
    tree->SetBranchAddress("pyf", t.py);
    tree->SetBranchAddress("pzf", t.pz);
    tree->SetBranchAddress("Ef", t.e);
    tree->SetBranchAddress("wght", &t.weight);
    tree->SetBranchAddress("Ev", &t.lepIn_E);
    tree->SetBranchAddress("A", &t.nucleus_A);
    tree->SetBranchAddress("Z", &t.nucleus_Z);    
    tree->SetBranchAddress("El",  &t.lepOut_E);
    tree->SetBranchAddress("pxl", &t.lepOut_Px);
    tree->SetBranchAddress("pyl", &t.lepOut_Py);
    tree->SetBranchAddress("pzl", &t.lepOut_Pz);
    tree->SetBranchAddress("hitnuc", &t.hitnuc);

    const float vx=0;
    const float vy=0;
    const float vz=0;

    for (int ievent = 0; ievent < tree->GetEntries(); ++ievent) {

        if (nevents > 0 && ievent >= nevents) break;

        tree->GetEvent(ievent);

        if (t.nf < 0 || t.nf > MAX_PARTICLES) {
            fprintf(stderr,
                "ERROR: Event %i has nf=%d; MAX_PARTICLES=%d\n",
                ievent, t.nf, MAX_PARTICLES
            );
            fclose(output); delete tree; exit(1);
         }

        // The event header:
        fprintf(output, "%lu ", t.nf+1);
        fprintf(output, "%i ", t.nucleus_A);
        fprintf(output, "%i ", t.nucleus_Z);        
        fprintf(output, "%i ", 0);
        fprintf(output, "%i ", 0);
        fprintf(output, "%.4e ", 0.000510999);
        fprintf(output, "%.4e ", t.lepIn_E);        
        fprintf(output, "%i ", t.hitnuc);
        fprintf(output, "%i ", t.evType);
        fprintf(output, "%.4e ", t.weight);
        fprintf(output, "\n");

        // The scattered lepton:
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
        for (int ipart = 0; ipart < t.nf; ipart++) {

            const int pdg = t.pid[ipart];

            TParticlePDG *p =
                TDatabasePDG::Instance()->GetParticle(pdg);
            fprintf(output, "%s ", "");
            fprintf(output, "%i ", ipart + 2);
            fprintf(output, "%i ", int(p->Charge()/3));
            fprintf(output, "%i ", 1);
            fprintf(output, "%i ", pdg);
            fprintf(output, "%i ", 0);
            fprintf(output, "%i ", 0);
            fprintf(output, "%.4e ", t.px[ipart]);
            fprintf(output, "%.4e ", t.py[ipart]);
            fprintf(output, "%.4e ", t.pz[ipart]);
            fprintf(output, "%.4e ", t.e[ipart]);
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
        printf("Usage: genie2lund #EVENTS\n");
        exit(1);
    }

    genie2lund(atoi(argv[1]));

    return 0;
}


