alias Soroban.Repo
alias Soroban.Service
alias Soroban.Jobtype
alias Soroban.Client
alias Soroban.User
alias Soroban.Setting

# Default admin user
Repo.insert!(%User{email: "admin@admin.com", username: "admin",
                   password_hash: Comeonin.Bcrypt.hashpwsalt("admin123"),
                   confirmed_at: Ecto.DateTime.utc})

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

Repo.insert!(%Setting{company_name: "Kickass Couriers", 
                      company_address: "123 My Street\nSF, CA 94111",
                      company_email: "gofast@test.com",
                      note: "Thanks For Using Kickass Couriers!"})
