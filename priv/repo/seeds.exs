alias Soroban.Repo
alias Soroban.Service
alias Soroban.Jobtype
alias Soroban.Client

for service <- ~w(Zoom Rush Regular) do
  Repo.get_by(Service, type: service) ||
    Repo.insert!(%Service{type: service})
end

Repo.insert!(%Jobtype{type: "Delivery: In-Town Bicycle"})
Repo.insert!(%Jobtype{type: "Delivery:  In-Town Vehicle"})
Repo.insert!(%Jobtype{type: "Delivery: Out-of-Town"})
Repo.insert!(%Jobtype{type: "Deliv. Addt'l Stop In-Town Vehicle"})
Repo.insert!(%Jobtype{type: "Filing/ Doc. Processing"})
Repo.insert!(%Jobtype{type: "Serve Attempt"})
Repo.insert!(%Jobtype{type: "Service of Process"})
Repo.insert!(%Jobtype{type: "Opposing Counsel Serve"})
Repo.insert!(%Jobtype{type: "Research/Doc. Retrieval"})
Repo.insert!(%Jobtype{type: "Research Addt'l Stop"})

Repo.insert!(%Client{name: "Dentons LLP", contact: "Accounts Payable",
                     address: "1 Market St., 24th Fl.\nSF, CA, 94104", 
                     email: "billing@denton.com"})

Repo.insert!(%Client{name: "Autumn Express", contact: "Accounts Payable",
                     address: "2121 Mission Street\nSF, CA, 94104", 
                     email: "billing@autumn.com"})

Repo.insert!(%Client{name: "VanVoorhis Law", contact: "Accounts Payable",
                     address: "601 Montgomery St, Suite 525\nSF, CA, 94104", 
                     email: "billing@vvs.com"})

