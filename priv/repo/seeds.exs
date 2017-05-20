alias Soroban.Repo
alias Soroban.Service
alias Soroban.Jobtype

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

